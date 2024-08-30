# coding=utf-8

################################################################################################
##                                                                                            ##
##     This file is part of XPRESSO, a QGIS plugin for xpressoulics                           ##
##     (see <http://xpresso-software.net/>).                                                  ##
##                                                                                            ##
##     Copyright (c) 2017 by HYDRA-SOFTWARE, which is a commercial brand                      ##
##     of Setec hydratec, Paris.                                                              ##
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


import sys
import os
import datetime
import codecs
import unicodedata
from qgis.PyQt.QtCore import QObject, pyqtSignal
from qgis.core import QgsProcessingFeedback

_cycle_dir = os.path.join(os.path.expanduser('~'), ".cycle")
_log_file = os.path.join(_cycle_dir, 'cycle.log')
    

class ConsoleLogger:
    def error(self, title, message):
        if sys.stderr is not None:
            sys.stderr.write(f"ERROR:{message}\n")

    def warning(self, title, message):
        if sys.stderr is not None:
            sys.stderr.write(f"WARNING: {message}\n")

    def notice(self, title, message):
        if sys.stdout is not None:
            sys.stdout.write(f"NOTICE: {message}\n")

class LogManager(QObject):

    error_signal = pyqtSignal(str, str)
    warning_signal = pyqtSignal(str, str)
    notice_signal = pyqtSignal(str, str)

    def __init__(self, logger=ConsoleLogger(), app_name="Cycle"):
        QObject.__init__(self)
        self.logger = logger
        self.title = app_name

    def error(self, message):
        normalized_message = self.__normalize(message)
        with codecs.open(_log_file, 'a') as file:
            file.write(f"\n{datetime.datetime.now().strftime('%d/%m/%Y %H:%M')}: ERROR\n{normalized_message}\n")
        self.logger.error(self.title, normalized_message)
        self.error_signal.emit(self.title, normalized_message)

    def warning(self, message):
        normalized_message = self.__normalize(message)
        with codecs.open(_log_file, 'a') as file:
            file.write(f"\n{datetime.datetime.now().strftime('%d/%m/%Y %H:%M')}: WARNING\n{normalized_message}\n")
        self.logger.warning(self.title, normalized_message)
        self.warning_signal.emit(self.title, normalized_message)

    def notice(self, message):
        normalized_message = self.__normalize(message)
        with codecs.open(_log_file, 'a') as file:
            file.write(f"\n{datetime.datetime.now().strftime('%d/%m/%Y %H:%M')}: NOTICE\n{normalized_message}\n")
        self.logger.notice(self.title, normalized_message)
        self.notice_signal.emit(self.title, normalized_message)

    def __normalize(self, message):
        return message
        try:
            if not isinstance(message, str) and sys.stdin.encoding is not None:
                message = message.decode(sys.stdin.encoding)
            normalized_message = str(unicodedata.normalize('NFKD', str(message)).encode('ASCII', 'ignore'))
        except:
            raise TypeError(f"Error handling following text in log manager:\n{message}")
        return normalized_message

    def cleanup(self):
        open(_log_file, 'w').close()


class Feedback(QgsProcessingFeedback):
    def __init__(self):
        super().__init__()
        self.__progress_text = ''
        self.__cr = ''

    def pushInfo(self, msg):
        sys.stdout.write(self.__cr+'info: '+msg+'\n')

    def pushConsoleInfo(self, msg):
        sys.stdout.write(self.__cr+'info: '+msg+'\n')

    def pushWarning(self, msg):
        sys.stderr.write(self.__cr+'warning: '+msg+'\n')

    def reportError(self, msg):
        sys.stderr.write(self.__cr+'error: '+msg+'\n')

    def setProgress(self, percent):
        sys.stdout.write(f'\r{self.__progress_text}{percent:.0f}%')
        self.__cr = '\n'
        if percent == 100:
            self.__cr = ''
            sys.stdout.write('\n')

    def setProgressText(self, txt):
        self.__progress_text = txt.strip() + ' '

