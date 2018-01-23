#!/usr/bin/env python3

import sys
import os
import stat
import subprocess as sp
import re

HOME_DIR = '.'
DIR_LINE = '├'
SUBDIR_LINE = '│'
LAST_DIR_LINE = '└'
CHAR_INDENT = '─'


def list_files(startpath, level, is_last):
	level += 1
	objects = os.listdir(startpath)
	dirs = [name for name in objects if os.path.isdir(os.path.join(startpath, name))]
	files = [name for name in objects if os.path.isfile(os.path.join(startpath, name))]

	dirs_count = len(dirs)
	files_count = len(files)

	for i in range(files_count):
		curr_name = files[i]
		prefix_a = '|   ' * level * (not is_last) + '   ' * level
		# prefix_b = ('\\' if (i + 1) == dirs_count else '') + '   '
		prefix_b = ''
		print('{}{}'.format(prefix_a + prefix_b, curr_name))

	for i in range(dirs_count):
		curr_name = dirs[i]

		if curr_name.startswith('.'):
			continue

		curr_obj_path = os.path.join(startpath, curr_name)
		if os.path.isdir(curr_obj_path):
			prefix_a = '|   ' * level
			prefix_b = ('\\' if (i + 1) == dirs_count else '+') + '---'
			print('{}{}'.format(prefix_a + prefix_b, curr_name))
			list_files(curr_obj_path, level, (i + 1) == dirs_count)
		else:
			# print(curr_name)
			pass

	# for root, dirs, files in os.walk(startpath):
	# 	if not (root.startswith(startpath + os.sep + '.') or root == startpath):
	# 		level = root.replace(startpath, '').count(os.sep)
	# 		indent = bool(level) * (('|' + ' ' * 4) * (level - 1)) + ('+' + '-' * 4)
	# 		print('{}{}'.format(indent, os.path.basename(root)))
	# 		sub_indent = '|' + ' ' * 4 * (level + 1)
	# 		for f in files:
	# 			if not f.startswith('.'):
	# 				print('{}{}'.format(sub_indent, f))

def is_hidden(file):
	return bool(os.stat(file).st_file_attributes & stat.FILE_ATTRIBUTE_HIDDEN)


def tree_dir(dir, tab_result=False):
	output = sp.run(['C:\\Windows\\System32\\tree.com', '/a', '/f', dir], stdout=sp.PIPE).stdout.decode('utf-8')
	match = re.findall(r'Volume.*?\r\r.*?\r\r(.*?)$', output.replace('\n', '\r'), flags=re.MULTILINE)[0]
	tree_result = match.replace('\r\r', '\r\n')
	if tab_result:
		return re.sub(r'^', '\t', tree_result, flags=re.MULTILINE)
	else:
		return tree_result


def print_usage():
	usage = 'Usage: update_readme.py [readme-template.md]\n\n readme-template\tSupply one or use default'


def main():
	list_files(HOME_DIR, 0, False)
	# print(tree_dir(HOME_DIR))
	pass


if __name__ == "__main__":
	if len(sys.argv) == 1:
		main()
	else:
		print_usage()
