import pandas as pd
import xlsxwriter
workload = pd.read_csv('c:\\temp\\1.csv')

maxlenofAlvin=0
maxlenofJason=0
maxlenofKevin=0
maxlenofKen=0

indexofall = workload.sort_values(["星期幾", "負責人"]).groupby(['星期幾','負責人']).groups
for key,values in indexofall.items():
    if key[1] == 'Alvin':
        if len(values) > maxlenofAlvin:
            maxlenofAlvin = len(values)
    if key[1] == 'Jason':
        if len(values) > maxlenofJason:
            maxlenofJason = len(values)
    if key[1] == 'Ken':
        if len(values) > maxlenofKen:
            maxlenofKen = len(values)
    if key[1] == 'Kevin':
        if len(values) > maxlenofKevin:
            maxlenofKevin = len(values)
			
print(maxlenofAlvin)			
print(maxlenofJason)
print(maxlenofKen)
print(maxlenofKevin)
maxlen = max(maxlenofAlvin, maxlenofJason, maxlenofKevin, maxlenofKen)

workbook = xlsxwriter.Workbook('tiis_workload.xlsx') # TODO 檔名加日期
worksheet = workbook.add_worksheet('工作表1')         # TODO 工作表加日期

row = 0
col = 0
worksheet.write(0, 0, '負責人')
worksheet.write(0, 1, '星期一')
worksheet.write(0, 2, '星期二')
worksheet.write(0, 3, '星期三')
worksheet.write(0, 4, '星期四')
worksheet.write(0, 5, '星期五')
worksheet.write(0, 6, '星期六')
worksheet.write(0, 7, '星期日')

worksheet.write(1, 0, 'Alvin')
worksheet.write(1+maxlen, 0, 'Jason')
worksheet.write(1+maxlen*2, 0, 'Ken')
worksheet.write(1+maxlen*3, 0, 'Kevin')

# for day in range(0,8):

#     row += 1
mon = workload.sort_values(["星期幾", "負責人"]).groupby('星期幾').groups['星期一']
tue = workload.sort_values(["星期幾", "負責人"]).groupby('星期幾').groups['星期二']
wed = workload.sort_values(["星期幾", "負責人"]).groupby('星期幾').groups['星期三']
thu = workload.sort_values(["星期幾", "負責人"]).groupby('星期幾').groups['星期四']
fri = workload.sort_values(["星期幾", "負責人"]).groupby('星期幾').groups['星期五']
# sat = workload.sort_values(["星期幾", "負責人"]).groupby('星期幾').groups['星期六']
# sun = workload.sort_values(["星期幾", "負責人"]).groupby('星期幾').groups['星期日']

# worksheet.write(0, 1, '星期一')


print(maxlen)

for counter, item in enumerate(mon):
    print(counter, item)
    col = 1
    if workload.iloc[item]['負責人'] == 'Alvin':        
        worksheet.write(counter +1 , col, workload.iloc[item]['工作內容'])
        diff_alvin = maxlenofAlvin - (counter + 1)
        continue
    if workload.iloc[item]['負責人'] == 'Jason':        
        worksheet.write(counter +1 + diff_alvin, col, workload.iloc[item]['工作內容'])
        diff_jason = maxlen + maxlenofJason - (counter + 1 + diff_alvin)
        continue
    if workload.iloc[item]['負責人'] == 'Ken':        
        worksheet.write(counter +1 + diff_jason + diff_alvin , col, workload.iloc[item]['工作內容'])
        diff_ken = maxlen*3 - (counter +1 + diff_jason + diff_alvin )
        continue
    if workload.iloc[item]['負責人'] == 'Kevin':        
        worksheet.write(counter + + diff_ken + diff_alvin +diff_jason , col, workload.iloc[item]['工作內容'])    
        continue


for counter, item in enumerate(tue):
    print(counter, item)
    col = 2
    if workload.iloc[item]['負責人'] == 'Alvin':        
        worksheet.write(counter +1 , col, workload.iloc[item]['工作內容'])
        diff_alvin = maxlenofAlvin - (counter + 1)
        continue
    if workload.iloc[item]['負責人'] == 'Jason':        
        worksheet.write(counter +1 + diff_alvin, col, workload.iloc[item]['工作內容'])
        diff_jason = maxlen + maxlenofJason - (counter + 1 + diff_alvin)
        continue
    if workload.iloc[item]['負責人'] == 'Ken':        
        worksheet.write(counter +1 + diff_jason + diff_alvin , col, workload.iloc[item]['工作內容'])
        diff_ken = maxlen*3 - (counter +1 + diff_jason + diff_alvin )
        continue
    if workload.iloc[item]['負責人'] == 'Kevin':        
        worksheet.write(counter + 1 + diff_ken + diff_alvin +diff_jason , col, workload.iloc[item]['工作內容'])    
        continue

for counter, item in enumerate(wed):
    print(counter, item)
    col = 3
    if workload.iloc[item]['負責人'] == 'Alvin':        
        worksheet.write(counter +1 , col, workload.iloc[item]['工作內容'])
        diff_alvin = maxlenofAlvin - (counter + 1)
        continue
    if workload.iloc[item]['負責人'] == 'Jason':        
        worksheet.write(counter +1 + diff_alvin, col, workload.iloc[item]['工作內容'])
        diff_jason = maxlen + maxlenofJason - (counter + 1 + diff_alvin)
        continue
    if workload.iloc[item]['負責人'] == 'Ken':        
        worksheet.write(counter +1 + diff_jason + diff_alvin , col, workload.iloc[item]['工作內容'])
        diff_ken = maxlen*3 - (counter +1 + diff_jason + diff_alvin )
        continue
    if workload.iloc[item]['負責人'] == 'Kevin':        
        worksheet.write(counter + 1 + diff_ken + diff_alvin +diff_jason , col, workload.iloc[item]['工作內容'])    
        continue


for counter, item in enumerate(thu):
    print(counter, item)
    col = 4
    if workload.iloc[item]['負責人'] == 'Alvin':        
        worksheet.write(counter +1 , col, workload.iloc[item]['工作內容'])
        diff_alvin = maxlenofAlvin - (counter + 1)
        continue
    if workload.iloc[item]['負責人'] == 'Jason':        
        worksheet.write(counter +1 + diff_alvin, col, workload.iloc[item]['工作內容'])
        diff_jason = maxlen + maxlenofJason - (counter + 1 + diff_alvin)
        continue
    if workload.iloc[item]['負責人'] == 'Ken':        
        worksheet.write(counter +1 + diff_jason + diff_alvin , col, workload.iloc[item]['工作內容'])
        diff_ken = maxlen*3 - (counter +1 + diff_jason + diff_alvin )
        continue
    if workload.iloc[item]['負責人'] == 'Kevin':        
        worksheet.write(counter + 1 + diff_ken + diff_alvin +diff_jason , col, workload.iloc[item]['工作內容'])    
        continue


for counter, item in enumerate(fri):
    print(counter, item)
    col = 5
    if workload.iloc[item]['負責人'] == 'Alvin':        
        worksheet.write(counter +1 , col, workload.iloc[item]['工作內容'])
        diff_alvin = maxlenofAlvin - (counter + 1)
        continue
    if workload.iloc[item]['負責人'] == 'Jason':        
        worksheet.write(counter +1 + diff_alvin, col, workload.iloc[item]['工作內容'])
        diff_jason = maxlen + maxlenofJason - (counter + 1 + diff_alvin)
        continue
    if workload.iloc[item]['負責人'] == 'Ken':        
        worksheet.write(counter +1 + diff_jason + diff_alvin , col, workload.iloc[item]['工作內容'])
        diff_ken = maxlen*3 - (counter +1 + diff_jason + diff_alvin )
        continue
    if workload.iloc[item]['負責人'] == 'Kevin':        
        worksheet.write(counter + 1 + diff_ken + diff_alvin +diff_jason , col, workload.iloc[item]['工作內容'])    
        continue




workbook.close()
