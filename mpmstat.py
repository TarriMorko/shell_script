"""A memstat parser.

使用範例

ipython day76_mpmstat.py C:\error

C:\error 是一個目錄，放置所有要處理的 error.log

檔名應該像這樣，副檔名是日期

error_log.01
error_log.02
error_log.03
error_log.04
...

"""

import sys
import re
from pathlib import Path
from dateutil.parser import parse
import datetime
import pandas as pd


parts = r'\[(?P<date>.+)] \[notice\]'
pattern = (re.compile(r'\[(?P<date>.+)] \[notice\].*rdy (?P<rdy>\d+) .*bsy (?P<bsy>\d+) '))

def parsing_mpmstat(filename: str):
    """Give a error_log, yield a record with 'date' and 'bsy'."""
    with open(filename, 'rt') as fout:
        for line in fout:
            m = pattern.match(line)
            if m:
                yield parse(m.groupdict()['date']), int(m.groupdict()['bsy'])

if __name__ == '__main__':
    """$ipython day76_memstat.py C:\src\temp"""

    main_working_directory = sys.argv[-1]
    p = Path(main_working_directory)
    filenames = [str(file) for file in p.rglob('error_log*')]


    start = datetime.datetime(2000, 1, 1,  8,0,0)
    end   = datetime.datetime(2000, 1, 1, 18,0,0)
    rng = pd.date_range(start, end, freq='T')
    rng = [ i.strftime('%H:%M') for i in rng ]
    df = pd.DataFrame(index=rng)
    ## 建立一個只有 index 的 DataFrame, index 是只有 %H:%M 的時間

    for file in filenames:
        print(file)       
        ts = pd.Series()
        for record in parsing_mpmstat(file):
            ts_ = pd.Series(record[1], index=[record[0]])
            ts = ts.append(ts_)
        print(record[0])
        # today = record[0] - datetime.timedelta(1)
        today = record[0] # 這有一個前提是那個檔案的最後一筆資料落在當天
        start = datetime.datetime(today.year, today.month, today.day,  8,0,0)
        end   = datetime.datetime(today.year, today.month, today.day, 18,0,0)
        ts = ts[start:end]
		# 把 ts 限制在某個時間區段內
		
        rng = pd.date_range(start, end, freq='T')
        ts = ts.resample('1Min').ffill().reindex(rng)
		# 將 ts 做 resampling, 以 rng 作為新的頻率, ffill 向前填補空位
		
        # 需要取得檔案名稱後綴
        file_post_fix = file.split('.')[-1]

        # 並以此名稱命名 column
        df[file_post_fix] = ts.values


        print(ts.describe())
        # ts.to_csv(file + '.csv')
        # with open(file + '.csv', 'w', newline='') as csvfile:
        #     spamwriter = csv.writer(csvfile, delimiter=' ',
        #                             quotechar='|', quoting=csv.QUOTE_MINIMAL)
        #     for line in ts.values:
        #         print(line)
        #         # spamwriter.writerow(line)
    
    df.to_csv('4p.csv')
