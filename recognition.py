import time

from container import Container
from device import Device
from object import RecObject
from settings import Settings

settings_instance = Settings.get_instance()

file_name = settings_instance.get_work_directory() + 'recognized.txt'
# print(file_name)
with open(file_name, 'r') as rec_file:
    # devices = []
    for line in rec_file:
        elements = line.rstrip().split(settings_instance.get_file_system_separator())
        print(elements)
       # print(len(elements))
        idx = 1
        parent_name = None
        container_id = None
        for element in elements:
            if idx < len(elements):
                print(str(idx) + ' element = ' + element)
                start_time = time.time()
                container = Container(element, parent_name)
                print("Container: %s seconds" % (time.time() - start_time))
                parent_name = element
                container_id = container.get_id()
            else:
                object_elements = element.split(':')

                device = object_elements[0].split('_')[0]
                start_time = time.time()
                device = Device(device)
                print("Device: %s seconds" % (time.time() - start_time))
                # devices.append(device)

                channel = object_elements[0].split('_')[1]
                start_time = time.time()
                device.add_channel(channel)
                print("Channel: %s seconds" % (time.time() - start_time))

                user = object_elements[0].split('_')[2]
                password = object_elements[0].split('_')[3].split('.')[0]
                start_time = time.time()
                device.add_login(user, password)
                print("Login: %s seconds" % (time.time() - start_time))

                obj = object_elements[1]
                probability = object_elements[2]
                start_time = time.time()
                rec_obj = RecObject(obj, device.get_channel_by_number(channel), container_id, probability)
                print("RecObject: %s seconds" % (time.time() - start_time))

                print(device.__dict__)

            idx += 1
        break

# supabase_obj = SupaBaseCams()
# data = supabase_obj.get_eq_dataset('class', '*', 'id', 1)
# print(data)
