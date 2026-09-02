#!/usr/bin/env python
"""URLReducer.py

Hadoop streaming Reducer for the UrlCount lab. Reads tab-delimited
"<url>\t<count>" pairs from STDIN, sums the count per URL, and emits only
URLs with a count greater than 5.
"""

import sys

CUTOFF = 5  # only report URLs referenced more than 5 times


def main():
    current_url = None
    current_count = 0

    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue

        url, count = line.split('\t', 1)
        try:
            count = int(count)
        except ValueError:
            continue

        if current_url == url:
            current_count += count
        else:
            if current_url is not None and current_count > CUTOFF:
                print('%s\t%s' % (current_url, current_count))
            current_url = url
            current_count = count

    # flush the last URL if it meets the cutoff
    if current_url is not None and current_count > CUTOFF:
        print('%s\t%s' % (current_url, current_count))


if __name__ == '__main__':
    main()
