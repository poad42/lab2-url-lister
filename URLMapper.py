#!/usr/bin/env python
"""URLMapper.py

Hadoop streaming Mapper for the UrlCount lab. Reads each input line from
STDIN, extracts every URL in an href="..." attribute, and emits one
tab-delimited "<url>\t1" pair per occurrence.
"""

import re
import sys

# Matches an href attribute value: the text between quotes after href=.
HREF_PATTERN = re.compile(r'href="([^"]*)"')


def main():
    for line in sys.stdin:
        line = line.strip()
        for match in HREF_PATTERN.finditer(line):
            url = match.group(1)
            # tab-delimited; the trivial url count is 1
            print('%s\t%s' % (url, 1))


if __name__ == '__main__':
    main()
