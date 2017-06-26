'''產生星展 DB2 的健檢報告.

執行範例：

::

    Run this program as below

        $ python f5_to_itnm.py

這個程式的作用：

1. 啊就是阿姆寄給你一個 zip 檔之後，用這個程式去產生一陀 docx.

'''

import os
import glob
import tarfile
import tempfile
import subprocess as sub
# 先找一個解壓縮後的位置
# D:\temp\20170621_DB2_HC

WORK_DIR = "D:\\temp\\20170621_DB2_HC"
os.chdir(WORK_DIR)
# for db2_file in glob.glob('*_HC*'):
#     database_name = db2_file[0:db2_file.find('_HC')]
#     for db2_diaglog in glob.glob('db2diag*' + database_name + '*'):
#         print(db2_file, db2_diaglog)
#         # db2_file: 存放 snapshot 跟 db2pd 一些有的沒的檔案
#         # db2_diaglog: 存放 db2diag
#         # 我需要建立一個 database_name 資料夾，然後把 db2_file, db2_diaglog 丟進去
#         # 然後 cd 進去解壓縮 all

def get_database_name():
    '''搜尋有 _HC 字樣的 gz 檔，把前面的字串當作資料庫名稱.
    
    databases = [x for x in get_database_name()]
    # 要用的時候就這樣 ['ACS', 'ARCHIVE', 'CARDDB', 'CMS', 'FCS', 'FEP']
    '''
    for db2_file in glob.glob('*_HC.tar.gz'):
        yield db2_file[0:db2_file.find('_HC.tar.gz')]

def extract_and_sort_out():
    '''解壓縮檔案，把 log 依照 db 分類到各自的資料夾.'''
    for db2_file in glob.glob('*_HC*'):
        database_name = db2_file[0:db2_file.find('_HC')]
        # os.mkdir(database_name)
        tar = tarfile.open(db2_file)
        for member in tar.getmembers():
            member.name = member.name.replace(':', '_')
        tar.extractall(path=database_name)
        tar.close()
        for db2_diaglog in glob.glob('db2diag*' + database_name + '*'):
            tar = tarfile.open(db2_diaglog)
            tar.extractall(path=database_name)
            tar.close()


def create_snapshot(snapshot):
    '''搞 snapshot.'''
    current_dir = os.getcwd()
    os.chdir('C:\\IBMtools\\snapshotAnalyzer_hc\\')
    sub.call([
        'java', '-cp', "SnapshotExtractor.jar",
        'com.ibm.db2.utils.SnapshotExtractor', snapshot], shell=True)
    os.chdir(current_dir)


def change_new_line(snapshot):
    '''需要一個函式去修改 snapshot 裡面的換行字元.'''
    

    # with open(snapshot) as inp, open('output.txt', 'w') as out:
    #     txt = inp.read()
    #     txt = txt.replace('\n', '\r\n')
    #     out.write(txt)
    # 這一段需要改良


def find_snapshot(target_dir):
    ''' 再做一個函式，遍歷所有的子目錄，把 *snapshot* 都送到 Analyzer 幹一下.'''
    for entry in os.scandir(target_dir):
        # print(entry.name)
        if entry.name.find('snapshot') >= 0: # 如果找到叫 snapshot 的
            snap_full_path = WORK_DIR + entry.path[1:]
            print(snap_full_path)
            create_snapshot(snap_full_path)
            # snap_full_path 是 snapshot 的完整路徑
            # 我為什麼不用 glob ? 腦殘了

        if entry.is_dir():
            find_snapshot(entry.path)


    # for file in glob.glob('*snapshot*'):
    #     sub.call([
    #         'java', '-cp', 'SnapshotExtractor.jar',
    #         'com.ibm.db2.utils.SnapshotExtractor', file], shell=True)    

def main():
    '''程式進入點.'''
    # extract_and_sort_out()
    # 是可以解壓縮然後歸類啦.....可是他媽的怎麼每個壓縮檔裡面格式都不一樣

    # 再做一個函式，遍歷所有的子目錄，把 *snapshot* 都送到 Analyzer 幹一下
    find_snapshot('.')

main()
