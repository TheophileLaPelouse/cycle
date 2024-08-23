# coding=utf-8

################################################################################################
##                                                                                            ##
##     This file is part of HYDRA, a QGIS plugin for hydraulics                               ##
##     (see <http://hydra-software.net/>).                                                    ##
##                                                                                            ##
##     Copyright (c) 2017 by HYDRA-SOFTWARE, which is a commercial brand                      ##
##     of Setec Hydratec, Paris.                                                              ##
##                                                                                            ##
##     Contact: <contact@hydra-software.net>                                                  ##
##                                                                                            ##
##     You can use this program under the terms of the GNU General Public                     ##
##     License as published by the Free Software Foundation, version 3 of                     ##
##     the License.                                                                           ##
##                                                                                            ##
##     You should have received a copy of the GNU General Public License                      ##
##     along with this program. If not, see <http://www.gnu.org/licenses/>.                   ##
##                                                                                            ##
################################################################################################


import re
import os
from qgis.PyQt import uic
from qgis.PyQt.QtWidgets import QDialog
from ...utility.string import normalized_model_name

class NewModelDialog(QDialog):
    def __init__(self, parent=None):
        QDialog.__init__(self, parent)
        current_dir = os.path.dirname(__file__)
        uic.loadUi(os.path.join(current_dir, "new_model_dialog.ui"), self)
        self.lblInfo.text=''
        self.edit_model_name.textChanged.connect(self.__edit_model_name_changed)
        self.model_name=None

    def __edit_model_name_changed(self):
        modelname = str(self.edit_model_name.text())
        new_modelname = normalized_model_name(modelname)
        self.lblInfo.setText("" if modelname==new_modelname else new_modelname)

    def return_name(self):
        return normalized_model_name(str(self.edit_model_name.text()))
