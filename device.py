from channel import Channel
from login import Login
from supabase_cams import SupaBaseCams

class Device:
    def __init__(self, ip):
        self.supabase_instance = SupaBaseCams.get_instance()
        self.ip = ip

        params = {
            'p_ip': self.ip
        }

        self.id = self.supabase_instance.get_by_function(
            'get_or_create_device'
            , params
        ).data

        self.channels = []
        self.logins = []

    def add_channel(self, number):
        channel = Channel(number, self.id)
        self.channels.append(channel)

    def add_login(self, user, password):
        login = Login(user, password, self.id)
        self.logins.append(login)

    def get_channel_by_number(self, number):
        for channel in self.channels:
            if channel.number == number:
                return channel.id
