import platform

class Settings:
    __instance = None
    __file_system_separator = None
    __file_system_root = None
    __work_directory = None

    @classmethod
    def get_instance(cls):
        if not cls.__instance:
            cls.__instance = Settings()

            if platform.system() == 'Windows':
                cls.__file_system_separator = '\\'
                cls.__file_system_root = 'C:'
                cls.__work_directory = 'C:\\PSP\\Photos_test\\'
            else:
                cls.__file_system_separator = '/'
                cls.__file_system_root = ''
                cls.__work_directory = '/home/psp/psp/Photos_test/'
        return Settings.__instance

    def get_file_system_separator(self):
        return self.__file_system_separator

    def get_file_system_root(self):
        return self.__file_system_root

    def get_work_directory(self):
        return self.__work_directory
