from idlelib.debugobj_r import remote_object_tree_item

from supabase_cams import SupaBaseCams

class Channel:
    def __init__(self, number, device_id):
        self.supabase_instance = SupaBaseCams.get_instance()
        self.number = number
        self.device_id = device_id

        params = {
            'p_number': self.number
            , 'p_device_id': self.device_id
        }

        self.id = self.supabase_instance.get_by_function(
            'get_or_create_channel'
            , params
        ).data

    def get_id(self):
        return self.id