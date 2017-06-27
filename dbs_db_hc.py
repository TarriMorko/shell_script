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
import shutil
import subprocess as sub
import docx
# 先找一個解壓縮後的位置
# D:\temp\20170621_DB2_HC

WORK_DIR = "D:\\temp\\20170621_DB2_HC"
SNAPSHOTANALYZER_DIR = "C:\\IBMtools\\snapshotAnalyzer_hc\\"
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
    '''搜尋有 _HC 字樣的 gz 檔，把前面的字串當作資料庫名稱.'''
    return [x[0:x.find('_HC.tar.gz')] for x in glob.glob('*_HC.tar.gz')]



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
    os.chdir(SNAPSHOTANALYZER_DIR)
    sub.call([
        'java', '-cp', "SnapshotExtractor.jar",
        'com.ibm.db2.utils.SnapshotExtractor', snapshot], shell=True)
    os.chdir(current_dir)


def change_new_line(snapshot):
    '''需要一個函式去修改 snapshot 裡面的換行字元.'''
    # 這一段需要改良 寫的真是醜
    with open(snapshot) as inp, open('temp.txt', 'w') as out:
        txt = inp.read()
        txt = txt.replace('\n', '\r\n')
        out.write(txt)
    os.remove(snapshot)
    os.rename('temp.txt', snapshot)


def find_snapshot(target_dir):
    ''' 再做一個函式，遍歷 WORK_DIR 所有的子目錄，把 *snapshot* 都送到 Analyzer 幹一下.'''
    for entry in os.scandir(target_dir):
        # print(entry.name)
        if entry.name.find('snapshot') >= 0: # 如果找到叫 snapshot 的
            snap_full_path = WORK_DIR + entry.path[1:]
            print(snap_full_path)
            change_new_line(snap_full_path)
            create_snapshot(snap_full_path)
            # 產生好的 snapshot 會增加 .csv 後綴
            # shutil.copy(SNAPSHOTANALYZER_DIR + entry.name, '.')
            # snap_full_path 是 snapshot 的完整路徑
            # 我為什麼不用 glob ? 腦殘了

        if entry.is_dir():
            find_snapshot(entry.path)




def put_log_in_docx():
    '''我需要一個函式，接收一個字串(mtrk)、使用這個字串去各個 db 資料夾
    得到含有該字串的文字檔，並將文字檔中的資料放進 docx .'''
    log_type = ['mtrk', 'dbptnmem', 'buff_']
    for log in log_type:
        for database in get_database_name():
            for file in glob.glob(database + '\\*' + log + '*'):
                print(file)
            # for file in glob.glob(database + '\\' + database + '_HC\\*' + log + '*'):
            #     print(file)





def main():
    '''程式進入點.'''
    # 下面這個函式是可以解壓縮然後歸類啦.....可是他媽的怎麼每個壓縮檔裡面格式都不一樣
    # extract_and_sort_out()

    # 再做一個函式，遍歷所有的子目錄，把 *snapshot* 都送到 Analyzer 幹一下
    # find_snapshot('.')

    # 得到資料庫名稱之後，導入各個 log
    # 找到 db2mtrk
    put_log_in_docx()

main()
