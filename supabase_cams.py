from supabase import create_client, Client

class SupaBaseCams:
    __instance = None
    __supabase: Client = None

    @classmethod
    def get_instance(cls):
        if not cls.__instance:
            url: str = 'https://civigctmwdofdulhsvjg.supabase.co'
            key: str = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNpdmlnY3Rtd2RvZmR1bGhzdmpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjgxMzQ1ODMsImV4cCI6MjA0MzcxMDU4M30.tv6SLAHQmgihcK3EDDX9_uQN6wvfufKrjfnMs_kquOA'
            cls.__supabase = create_client(url, key)
            cls.__instance = SupaBaseCams()
        return SupaBaseCams.__instance

    def get_eq_dataset(self, table, columns, eq_column, eq_value):
        data_set = (
            SupaBaseCams.__supabase
            .table(table)
            .select(columns)
            .eq(eq_column, eq_value)
            .execute()
        )
        return data_set

    def get_match_dataset(self, table, columns, json_match):
        data_set = (
            SupaBaseCams.__supabase
            .table(table)
            .select(columns)
            .match(json_match)
            .execute()
        )
        return data_set

    def insert_row(self, table, json_row):
        data_set = (
            SupaBaseCams.__supabase
            .table(table)
            .insert(json_row)
            .execute()
        )
        return data_set