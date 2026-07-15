def is_update_available(current_ver, current_build_str, latest_ver_with_build):
    latest_parts = latest_ver_with_build.split('+')
    latest_ver = latest_parts[0]
    latest_build_str = latest_parts[1] if len(latest_parts) > 1 else '0'

    current_sem = [int(e) if e.isdigit() else 0 for e in current_ver.split('.')]
    latest_sem = [int(e) if e.isdigit() else 0 for e in latest_ver.split('.')]

    while len(current_sem) < 3:
        current_sem.append(0)
    while len(latest_sem) < 3:
        latest_sem.append(0)

    for i in range(3):
        if latest_sem[i] > current_sem[i]:
            return True
        if current_sem[i] > latest_sem[i]:
            return False

    latest_build = int(latest_build_str) if latest_build_str.isdigit() else 0
    current_build = int(current_build_str) if current_build_str.isdigit() else 0
    return latest_build > current_build

print("2.5.0+2028 vs 2.5.0+20028:", is_update_available("2.5.0", "2028", "2.5.0+20028"))
print("2.5.0+20028 vs 2.5.0+20028:", is_update_available("2.5.0", "20028", "2.5.0+20028"))
