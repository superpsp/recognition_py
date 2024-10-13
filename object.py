from supabase_cams import SupaBaseCams


class RecObject:
    def __init__(self, name, channel_id, container_id, probability):
        self.supabase_instance = SupaBaseCams.get_instance()
        self.name = name
        self.channel_id = channel_id
        self.container_id = container_id
        self.probability = probability

        params = {
            'p_name': self.name
            , 'p_channel_id': self.channel_id
            , 'p_container_id': self.container_id
            , 'p_probability': self.probability
        }

        self.id = self.supabase_instance.get_by_function(
            'get_or_create_object'
            , params
        ).data
