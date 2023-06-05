import sys

kevent = {
        'R': 'KEYCODE_DPAD_RIGHT',
        'L': 'KEYCODE_DPAD_LEFT',
        'U': 'KEYCODE_DPAD_UP',
        'D': 'KEYCODE_DPAD_DOWN',
        'OK': 'KEYCODE_DPAD_CENTER',
        'TAB': 'KEYCODE_TAB',
        'BACK': 'KEYCODE_BACK',
        'SETTINGS': 'KEYCODE_SETTINGS',
        'ENTER': 'KEYCODE_ENTER',
        'DEL': 'KEYCODE_DEL',
        'FDEL': 'KEYCODE_FORWARD_DEL'
}

for i in range(10):
    kevent[str(i)] = 'KEYCODE_' + str(i)

with open(sys.argv[1]) as f:
    lines = f.readlines()
    for line in lines:
        tokens = line.strip().split(' ')
        cmd = tokens[0]
        if cmd.startswith("#") or not cmd:
            continue
        
        if cmd == 'TEXT':
            base = f'input text "{tokens[1]}"'
            print(base)

        elif cmd == 'SLEEP':
            base = f'sleep {tokens[1]}'
            print(base)

        else:
            count = 1
            if len(tokens) > 1:
                count = int(tokens[1])

            base = 'input keyevent '
            for i in range(count):
                print(base, end="")
                print(kevent[cmd])
