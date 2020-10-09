#!/usr/bin/env python3

import sys
import os
import stat

HOME_DIR = '.'
DIR = '├'
SUBDIR = '│'
LAST_DIR = '└'
INDENT = '─'

# ascii version
# DIR = '+'
# SUBDIR = '|'
# LAST_DIR = '\'
# INDENT = '-'

IGNORE_LIST = ['.idea', 'maintenance']


def list_files(startpath, level, is_last, prefix):
	treeString = ''
	objects = os.listdir(startpath)
	dirs = [name for name in objects if os.path.isdir(os.path.join(startpath, name))]
	files = [name for name in objects if os.path.isfile(os.path.join(startpath, name))]

	dirs_count = len(dirs)
	files_count = len(files)

	for i in range(files_count):
		curr_name = files[i]
		b_level, b_dirs = bool(level), bool(dirs_count)
		
		prefix_a = prefix + (SUBDIR + '   ') * b_level * b_dirs
		prefix_b = ('    ' * is_last) + \
					((SUBDIR + '   ') * (not is_last) * b_level) + \
				 	('    ' * b_level * (not b_dirs))

		output = '{}{}{}'.format(prefix_a, prefix_b, curr_name)
		treeString += output + '\n'
		# print(output)

		if ((i + 1) == files_count):
			output = prefix_a + prefix_b
			treeString += output + '\n'
			# print(output)

	for i in range(dirs_count):
		curr_name = dirs[i]

		if ignore_object((startpath, curr_name)):
			continue

		curr_obj_path = os.path.join(startpath, curr_name)
		if os.path.isdir(curr_obj_path):
			prefix_a = prefix + '    ' if is_last else (SUBDIR + '   ') * level
			prefix_b = (LAST_DIR if (i + 1) == dirs_count else DIR) + INDENT*3

			output = '{}{}{}'.format(prefix_a, prefix_b, curr_name)
			treeString += output + '\n'
			# print(output)
			
			treeString += list_files(curr_obj_path, level + 1, (i + 1) == dirs_count, prefix_a)

			if (is_last):
				output = prefix
				treeString += output + '\n'
				# print(output)

	return treeString
			

def is_hidden(file):
	return bool(os.stat(file).st_file_attributes & stat.FILE_ATTRIBUTE_HIDDEN)


def ignore_object(name):
	return is_hidden(name[0]) or (name[1] in IGNORE_LIST) or (name[1].endswith('.git'))


def print_usage():
	usage = 'Usage: update_readme.py [readme-template.md]\n\n readme-template\tSupply one or use default'
	print(usage)


def main():
	tree = list_files(HOME_DIR, 0, False, (SUBDIR + '   '))
	tree = '.\n{}\n{}'.format(SUBDIR, tree)
	print(tree)
	pass


if __name__ == "__main__":
	if len(sys.argv) == 1:
		main()
	else:
		print_usage()
