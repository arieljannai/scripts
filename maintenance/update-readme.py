#!/usr/bin/env python3

import sys
import os
import stat
# import subprocess as sp
# import re

HOME_DIR = '.'
DIR = '├'
SUBDIR = '│'
LAST_DIR = '└'
INDENT = '─'
# D, S, L, C = '    '
# SP = ' '
IGNORE_LIST = ['.idea', 'maintenance']


def list_files(startpath, level, is_last, prefix):
	level += 1
	objects = os.listdir(startpath)
	dirs = [name for name in objects if os.path.isdir(os.path.join(startpath, name))]
	files = [name for name in objects if os.path.isfile(os.path.join(startpath, name))]

	dirs_count = len(dirs)
	files_count = len(files)

	for i in range(files_count):
		curr_name = files[i]
		prefix_a = (prefix + (SUBDIR + '   ') * bool(level - 1) * bool(dirs_count))
		prefix_b = ('    ' * is_last) + \
					((SUBDIR + '   ') * (not is_last) * (bool(level - 1))) + \
				 	('    ' * (is_last or bool(level - 1) and (not bool(dirs_count))))
		print('{}{}'.format(prefix_a + prefix_b, curr_name))

		if ((i + 1) == files_count):
			print(prefix_a + prefix_b)


	for i in range(dirs_count):
		curr_name = dirs[i]

		if ignore_object((startpath, curr_name)):
			continue

		curr_obj_path = os.path.join(startpath, curr_name)
		if os.path.isdir(curr_obj_path):
			prefix_a = prefix + '    ' if is_last else (SUBDIR + '   ') * (level - 1)
			prefix_b = (LAST_DIR if (i + 1) == dirs_count else DIR) + INDENT*3
			print('{}{}'.format(prefix_a + prefix_b, curr_name))
			
			list_files(curr_obj_path, level, (i + 1) == dirs_count, prefix_a)

			if (is_last):
				print(prefix)
			

# def tree_dir(dir, tab_result=False):
# 	output = sp.run(['C:\\Windows\\System32\\tree.com', '/a', '/f', dir], stdout=sp.PIPE).stdout.decode('utf-8')
# 	match = re.findall(r'Volume.*?\r\r.*?\r\r(.*?)$', output.replace('\n', '\r'), flags=re.MULTILINE)[0]
# 	tree_result = match.replace('\r\r', '\r\n')
# 	if tab_result:
# 		return re.sub(r'^', '\t', tree_result, flags=re.MULTILINE)
# 	else:
# 		return tree_result

def is_hidden(file):
	return bool(os.stat(file).st_file_attributes & stat.FILE_ATTRIBUTE_HIDDEN)


def ignore_object(name):
	return is_hidden(name[0]) or (name[1] in IGNORE_LIST) or (name[1].endswith('.git'))


# def set_print_mode(fancy, indent_num):
# 	if (fancy):
# 		D, S, L, C = DIR_LINE, SUBDIR_LINE, LAST_DIR_LINE, CHAR_INDENT
# 	else:
# 		D, S, L, C = '+', '|', '\\', '-'
	
# 	n = indent_num - 1
# 	D, S, L, C, SP = D*n, S*n, L*n, C*n, SP*indent_num


def print_usage():
	usage = 'Usage: update_readme.py [readme-template.md]\n\n readme-template\tSupply one or use default'
	print(usage)


def main():
	list_files(HOME_DIR, 0, False, (SUBDIR + '   '))
	# print(tree_dir(HOME_DIR))
	pass


if __name__ == "__main__":
	if len(sys.argv) == 1:
		main()
	else:
		print_usage()
