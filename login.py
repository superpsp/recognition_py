from supabase_cams import SupaBaseCams

class Login:
    def __init__(self, user, password, device_id):
        self.supabase_instance = SupaBaseCams.get_instance()
        self.user = user
        self.password = password
        self.device_id = device_id

        params = {
            'p_user_name': self.user
            , 'p_password': self.password
        }

        self.id = self.supabase_instance.get_by_function(
            'get_or_create_login'
            , params
        ).data

        params = {
            'p_device_id': self.device_id
            , 'p_login_id': self.id
        }

        self.device_login_id = self.supabase_instance.get_by_function(
            'get_or_create_device_login'
            , params
        ).data
