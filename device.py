from channel import Channel
from login import Login
from supabase_cams import SupaBaseCams

class Device:
    def __init__(self, ip):
        self.supabase_instance = SupaBaseCams.get_instance()
        self.ip = ip

        data = self.supabase_instance.get_eq_dataset('device', 'id', 'ip', self.ip)
        if 'id' not in data.json():
            json_row = {'ip': self.ip}
            data = self.supabase_instance.insert_row('device', json_row)
        self.id = data.data.__getitem__(0)['id']

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
