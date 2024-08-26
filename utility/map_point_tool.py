# coding=utf-8

from qgis.gui import QgsMapTool, QgsRubberBand
from qgis.core import QgsPointXY, QgsWkbTypes
from qgis.PyQt.QtGui import QColor
from qgis.PyQt.QtWidgets import QApplication
from qgis.PyQt.QtCore import Qt
from qgis.PyQt.QtCore import pyqtSignal
from shapely.geometry import LineString, Point

try:
    from rtree import index
except:
    from cycle.rtree import index

class VisibleGeometry(object):
    """a class that holds a reference to a rubberband
    and does the cleanup an deletion,
    the class converts to WKT string automagically
    """
    def __init__(self, canvas, geom_type, color=None, points=None):
        self.__canvas = canvas
        self.__band = QgsRubberBand(self.__canvas, geom_type)
        self.__band.setColor(color or Qt.red)
        self.__points = None
        self.__type = geom_type
        self.__preview_band = QgsRubberBand(self.__canvas, geom_type) if not self.__type == QgsWkbTypes.PointGeometry else None
        if self.__preview_band is not None:
            self.__preview_band.setColor(color or Qt.red)

        self.clear()
        if points is not None:
            for point in points:
                self.add_point(point)

    def remove_from_canvas(self):
        self.__canvas.scene().removeItem(self.__band)
        self.__preview_band and self.__canvas.scene().removeItem(self.__preview_band)

    def __del__(self):
        self.__canvas.scene().removeItem(self.__band)
        self.__preview_band and self.__canvas.scene().removeItem(self.__preview_band)

    def __getitem__(self, idx):
       return self.__points[idx]

    def add_point(self, point):
        if self.__type == QgsWkbTypes.PolygonGeometry:
            self.__points[0].append(point)
        elif self.__type == QgsWkbTypes.LineGeometry:
            self.__points.append(point)
        elif self.__type == QgsWkbTypes.PointGeometry:
            self.__points = point
        self.__band.addPoint(QgsPointXY(point[0], point[1]))
        if self.__preview_band is not None:
            if self.__preview_band.numberOfVertices()==0:
                self.__preview_band.addPoint(QgsPointXY(point[0], point[1]))
                self.__preview_band.addPoint(QgsPointXY(point[0], point[1]))
            else:
                self.__preview_band.movePoint(0,QgsPointXY(point[0], point[1]))

    def update_preview_pos(self, point):
        if self.__preview_band is not None and self.__preview_band.numberOfVertices()==2:
            self.__preview_band.movePoint(1,QgsPointXY(point[0], point[1]))

    def remove_last_point(self):
        if self.__type == QgsWkbTypes.PolygonGeometry:
            if len(self.__points)>0:
                self.__points[0].pop()
        elif self.__type == QgsWkbTypes.LineGeometry:
            if len(self.__points)>0:
                self.__points.pop()
        elif self.__type == QgsWkbTypes.PointGeometry:
            self.__points = None
        self.__band.removeLastPoint()

        if self.__preview_band is not None:
            if self.__preview_band.numberOfVertices()==2:
                if len(self.__points)>0:
                    i_point = len(self.__points)-1
                    self.__preview_band.movePoint(0,QgsPointXY(self.__points[i_point][0], self.__points[i_point][1]))
                else:
                    self.__preview_band.reset(self.__type)

    def __len__(self):
        return len(self.__points) if self.__points else 0

    def clear_preview_band(self):
        if self.__preview_band is not None:
            self.__preview_band.reset(self.__type)

    def clear(self):
        if self.__type == QgsWkbTypes.PolygonGeometry:
            self.__points = [[]]
        elif self.__type == QgsWkbTypes.LineGeometry:
            self.__points = []
        elif self.__type == QgsWkbTypes.PointGeometry:
            self.__points = None
        else:
            raise RuntimeError("unhandled geometry type")
        self.__band.reset(self.__type)
        self.clear_preview_band()

class Snapper(object):
    def __init__(self, distance=10):
        self.__index_points = index.Index()
        self.__points = []
        self.__segments = []
        self.__segments_id = []
        self.__max_distance_squared = distance*distance
        self.__last_segment_id = None

    @staticmethod
    def __distance_squared(p, q):
        pq = (q[0] - p[0], q[1] - p[1])
        return pq[0]*pq[0] + pq[1]*pq[1]

    @staticmethod
    def __nearest_point_from_segment(segment, point):
        line = LineString(segment)
        p = Point(point[0],point[1])
        np = line.interpolate(line.project(p))
        return np.x, np.y

    def add_point(self, point):
        self.__index_points.insert(len(self.__points), (point[0], point[1], point[0], point[1]))
        self.__points.append(point)

    def add_points(self, points):
        for point in points:
            self.add_point(point)

    def add_segment(self, segment, id_segment=None):
        self.__segments.append(segment)
        self.__segments_id.append(id_segment)

    def nearest_from_segments(self, point, point_np):
        index_nearest_points = index.Index()
        nearest_points = []
        id_segment = []

        if not (point[0]==point_np[0] and point[1]==point_np[1]):
            index_nearest_points.insert(len(nearest_points), (point_np[0], point_np[1], point_np[0], point_np[1]))
            nearest_points.append(point_np)
            id_segment.append(None)

        for i in range(0,len(self.__segments)):
            seg = self.__segments[i]
            id_segment.append(self.__segments_id[i])
            np = Snapper.__nearest_point_from_segment(seg, point)
            index_nearest_points.insert(len(nearest_points), (np[0], np[1], np[0], np[1]))
            nearest_points.append(np)

        nearest = list(index_nearest_points.nearest((point[0], point[1], point[0], point[1]), 1))

        if len(nearest) > 0 and Snapper.__distance_squared(nearest_points[nearest[0]], point) < self.__max_distance_squared:
            result = nearest_points[nearest[0]]
            self.__last_segment_id = id_segment[nearest[0]]
        else:
            result = point
            self.__last_segment_id = None
        return result

    def last_segment_id(self):
        return self.__last_segment_id

    def nearest(self, point):
        np = self.nearest_from_points(point)
        if not (point[0]==np[0] and point[1]==np[1]):
            return np
        else:
            return self.nearest_from_segments(point, np)

    def nearest_from_points(self, point):
        nearest = list(self.__index_points.nearest((point[0], point[1], point[0], point[1]), 1))
        return self.__points[nearest[0]] \
                if len(nearest) > 0 \
                and Snapper.__distance_squared(self.__points[nearest[0]], point) < self.__max_distance_squared \
                else point

    def remove_last(self):
        if len(self.__points):
            point = self.__points.pop()
            self.__index_points.delete(len(self.__points), (point[0], point[1], point[0], point[1]))


class MapPointTool(QgsMapTool):
    leftClicked = pyqtSignal(tuple)
    rightClicked = pyqtSignal(tuple)
    moved = pyqtSignal(tuple)
    undo = pyqtSignal()

    def __init__(self, canvas, log_manager, terrain = None, snapper=None):
        QgsMapTool.__init__(self, canvas)
        self.__canvas = canvas
        self.__log = log_manager
        self.__terrain = terrain
        self.setCursor(Qt.CrossCursor)
        self.__snapper = snapper
        self.__point_display = VisibleGeometry(canvas, QgsWkbTypes.PointGeometry, Qt.green)

    def canvasPressEvent(self, event):
        pass

    def keyPressEvent(self, event):
        if event.key()==(Qt.Key_Control and Qt.Key_Z):
            self.undo.emit()
        QgsMapTool.keyPressEvent(self, event)

    def __snap(self, qgs_point):
        if self.__snapper:
            nearest = self.__snapper.nearest((qgs_point.x(), qgs_point.y()))
            qgs_point = QgsPointXY(nearest[0], nearest[1])
            self.__point_display.clear()
            self.__point_display.add_point(nearest)
        return qgs_point


    def canvasMoveEvent(self, event):
        x = event.pos().x()
        y = event.pos().y()
        point = self.__snap(self.__canvas.getCoordinateTransform().toMapCoordinates(x, y))
        self.moved.emit(
                (point.x(), point.y(), self.__terrain.altitude(point, no_warning=True))
                if self.__terrain else (point.x(), point.y(), 99999))

    def canvasReleaseEvent(self, event):
        #Get the click
        x = event.pos().x()
        y = event.pos().y()
        point = self.__snap(self.__canvas.getCoordinateTransform().toMapCoordinates(x, y))

        ret = (point.x(), point.y(), self.__terrain.altitude(point, no_warning=True)) \
                if self.__terrain else (point.x(), point.y(), 99999)

        if event.button() == Qt.RightButton:
            self.rightClicked.emit(ret)
        else:
            self.leftClicked.emit(ret)

    def isZoomTool(self):
        return False

    def isTransient(self):
        return False

    def isEditTool(self):
        return True

def create_pointz(canvas, log_manager, terrain=None, snapper=None):
    return create_point(canvas, log_manager, terrain, snapper)

def create_point(canvas, log_manager, terrain=None, snapper=None):
    """return a point after user has clicked on canvas,
    while the point exist, a rubberband is drawn on canvas

    if user select another tool or right_click None is returned"""

    geom = VisibleGeometry(canvas, QgsWkbTypes.PointGeometry)
    old_tool = canvas.mapTool()

    def on_left_click(point):
        geom.add_point(point)
        canvas.setMapTool(old_tool)

    def on_right_click(point):
        canvas.setMapTool(old_tool)

    tool = MapPointTool(canvas, log_manager, terrain, snapper)
    tool.leftClicked.connect(on_left_click)
    tool.rightClicked.connect(on_right_click)
    canvas.setMapTool(tool)

    while canvas.mapTool() == tool:
        QApplication.instance().processEvents()

    tool.setParent(None)
    del tool

    return geom if len(geom) > 0 else None

def create_segmentz(canvas, log_manager, terrain=None, snapper=None, end_snapper=None):
    return create_segment(canvas, log_manager, terrain, snapper, end_snapper)

def create_segment(canvas, log_manager, terrain=None, snapper=None, end_snapper=None):
    """return a segment after user has clicked twice on canvas,
    while the segment exist, a rubberband is drawn on canvas

    if user select another tool or right_click None is returned

    Possibility to orient segment by giving an end snapper
    then the segment can only be created from entities in
    snapper to entities in snapper_end"""

    geom = VisibleGeometry(canvas, QgsWkbTypes.LineGeometry)
    old_tool = canvas.mapTool()

    def on_left_click(point):
        geom.add_point(point)
        if len(geom) > 0:
            canvas.setMapTool(old_tool)

    def on_right_click(point):
        geom.clear_preview_band()
        canvas.setMapTool(old_tool)

    def on_moved(point):
        geom.update_preview_pos(point)

    if end_snapper is None:
        end_snapper = snapper

    tool1 = MapPointTool(canvas, log_manager, terrain, snapper)
    tool1.leftClicked.connect(on_left_click)
    tool1.rightClicked.connect(on_right_click)
    tool1.moved.connect(on_moved)
    canvas.setMapTool(tool1)
    while canvas.mapTool() == tool1:
        QApplication.instance().processEvents()

    tool1.setParent(None)
    del tool1

    tool2 = MapPointTool(canvas, log_manager, terrain, end_snapper)
    tool2.leftClicked.connect(on_left_click)
    tool2.rightClicked.connect(on_right_click)
    tool2.moved.connect(on_moved)
    canvas.setMapTool(tool2)
    while canvas.mapTool() == tool2:
        QApplication.instance().processEvents()

    tool2.setParent(None)
    del tool2

    return geom if len(geom) == 2 else None

def create_linez(canvas, log_manager, terrain=None, snapper=None):
    return create_line(canvas, log_manager, terrain, snapper)

def create_line(canvas, log_manager, terrain=None, snapper=None):
    """return a line after user has clicked several times
    on canvas and then riht-clicked, while the line exist, a
    rubberband is drawn on canvas

    if user select another tool or right_click None is returned"""

    geom = VisibleGeometry(canvas, QgsWkbTypes.LineGeometry)
    old_tool = canvas.mapTool()

    snapper = snapper or Snapper(10)

    def on_left_click(point):
        geom.add_point(point)
        if len(geom) == 1:
            snapper.add_point(geom[0])

    def on_right_click(point):
        geom.clear_preview_band()
        canvas.setMapTool(old_tool)

    def on_moved(point):
        geom.update_preview_pos(point)

    def on_undo():
        if len(geom) == 1:
            snapper.remove_last()
        geom.remove_last_point()

    tool = MapPointTool(canvas, log_manager, terrain, snapper)
    tool.leftClicked.connect(on_left_click)
    tool.rightClicked.connect(on_right_click)
    tool.moved.connect(on_moved)
    tool.undo.connect(on_undo)
    canvas.setMapTool(tool)

    while canvas.mapTool() == tool:
        QApplication.instance().processEvents()

    tool.setParent(None)
    del tool

    return geom if len(geom) >= 2 else None

def create_polygon(canvas, log_manager, terrain=None, snapper=None, first_point=None):
    """return a polygon after user has clicked on canvas and returned
    to the first point, while the polygon exist, a rubberband is drawn
    on canvas

    if user select another tool or right_click None is returned"""
    color = QColor(255,0,0,64)
    geom = VisibleGeometry(canvas, QgsWkbTypes.PolygonGeometry, color)
    if first_point:
        geom.add_point(first_point)
    old_tool = canvas.mapTool()

    snapper = snapper or Snapper(10)
    tool = MapPointTool(canvas, log_manager, terrain, snapper)

    def on_left_click(point):
        if point not in geom[0]:
            geom.add_point(point)

        if len(geom[0]) > 2 and geom[0][0] == point:
            geom.add_point(point)
            canvas.setMapTool(old_tool)

        if len(geom[0]) == 1:
            snapper.add_point(geom[0][0])

    def on_right_click(point):
        geom.clear_preview_band()
        canvas.setMapTool(old_tool)

    def on_moved(point):
        geom.update_preview_pos(point)

    def on_undo():
        geom.remove_last_point()
        snapper.remove_last()

    tool.leftClicked.connect(on_left_click)
    tool.rightClicked.connect(on_right_click)
    tool.moved.connect(on_moved)
    tool.undo.connect(on_undo)
    canvas.setMapTool(tool)

    while canvas.mapTool() == tool:
        QApplication.instance().processEvents()

    tool.setParent(None)
    del tool

    return geom if len(geom[0]) > 2 and geom[0][0] == geom[0][-1] else None



