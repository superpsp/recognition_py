from supabase_cams import SupaBaseCams

class Login:
    def __init__(self, user, password, device_id):
        self.supabase_instance = SupaBaseCams.get_instance()
        self.user = user
        self.password = password
        self.device_id = device_id

        data = self.supabase_instance.get_match_dataset('login', 'id', {'user': self.user, 'password': self.password})
        if 'id' not in data.json():
            json_row = {'user': self.user, 'password': self.password}
            data = self.supabase_instance.insert_row('login', json_row)
        self.id = data.data.__getitem__(0)['id']

        data = self.supabase_instance.get_match_dataset('device_login', 'id', {'device_id': self.device_id, 'login_id': self.id})
        if 'id' not in data.json():
            if user == 'admin':
                json_row = {'device_id': self.device_id, 'login_id': self.id, 'is_default': 'y'}
            else:
                json_row = {'device_id': self.device_id, 'login_id': self.id}
            data = self.supabase_instance.insert_row('device_login', json_row)
        self.device_login_id = data.data.__getitem__(0)['id']
