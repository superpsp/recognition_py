from idlelib.debugobj_r import remote_object_tree_item

from supabase_cams import SupaBaseCams

class Channel:
    def __init__(self, number, device_id):
        self.supabase_instance = SupaBaseCams.get_instance()
        self.number = number
        self.device_id = device_id

        data = self.supabase_instance.get_eq_dataset('channel', 'id', 'number', self.number)
        if 'id' not in data.json():
            json_row = {'number': self.number, 'device_id': self.device_id}
            data = self.supabase_instance.insert_row('channel', json_row)
        self.id = data.data.__getitem__(0)['id']

    def get_id(self):
        return self.id