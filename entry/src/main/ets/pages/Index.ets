// entry/src/main/ets/pages/Index.ets
import common from '@ohos.app.ability.common';
import { DataStorage } from '../common/DataStorage';

// 直接在Index.ets中定义接口，避免导入问题
interface AccountRecord {
  type: string;
  amount: number;
  remark: string;
  time: string;
}

@Entry
@Component
struct AccountBook {
  @State income: string = '';
  @State expense: string = '';
  @State remark: string = '';
  @State records: AccountRecord[] = [];
  private storage: DataStorage | null = null;

  aboutToAppear() {
    const ctx = getContext() as common.UIAbilityContext;
    this.storage = new DataStorage(ctx);
    this.loadRecords();
  }

  async loadRecords() {
    if (!this.storage) return;
    const data = await this.storage.get('records');
    if (data) {
      try {
        this.records = JSON.parse(data);
      } catch (e) {
        console.error('解析记录失败:', e);
      }
    }
  }

  async addRecord(type: string, amountStr: string) {
    if (!amountStr || !this.storage) return;

    const amount = parseFloat(amountStr);
    if (isNaN(amount) || amount <= 0) return;

    const now = new Date();
    const time = `${now.getMonth() + 1}-${now.getDate()} ${now.getHours()}:${now.getMinutes()}`;

    const newRecord: AccountRecord = {
      type: type,
      amount: amount,
      remark: this.remark || (type === '收入' ? '收入' : '支出'),
      time: time
    };

    this.records.unshift(newRecord);
    await this.storage.save('records', JSON.stringify(this.records));

    // 清空输入
    if (type === '收入') {
      this.income = '';
    } else {
      this.expense = '';
    }
    this.remark = '';
  }

  async deleteRecord(index: number) {
    if (!this.storage) return;
    this.records.splice(index, 1);
    await this.storage.save('records', JSON.stringify(this.records));
  }

  // 计算总额
  calculateTotal(type: string): number {
    let total = 0;
    for (const record of this.records) {
      if (record.type === type) {
        total += record.amount;
      }
    }
    return total;
  }

  getTotalIncome(): number {
    return this.calculateTotal('收入');
  }

  getTotalExpense(): number {
    return this.calculateTotal('支出');
  }

  getBalance(): number {
    return this.getTotalIncome() - this.getTotalExpense();
  }

  build() {
    Column() {
      // 标题
      Text('个人记账本')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 30, bottom: 20 });

      // 统计信息
      Row() {
        Column() {
          Text('总收入')
            .fontSize(14)
            .fontColor('#666666');
          Text('¥' + this.getTotalIncome().toFixed(2))
            .fontSize(20)
            .fontColor('#008000');
        }
        .width('33%')

        Column() {
          Text('总支出')
            .fontSize(14)
            .fontColor('#666666');
          Text('¥' + this.getTotalExpense().toFixed(2))
            .fontSize(20)
            .fontColor('#FF0000');
        }
        .width('33%')

        Column() {
          Text('余额')
            .fontSize(14)
            .fontColor('#666666');
          Text('¥' + this.getBalance().toFixed(2))
            .fontSize(20)
            .fontColor(this.getBalance() >= 0 ? '#008000' : '#FF0000');
        }
        .width('33%')
      }
      .width('90%')
      .padding(10)
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .margin({ bottom: 20 });

      // 收入输入
      Row() {
        Text('收入：')
          .fontSize(18)
          .width(60);
        TextInput({ text: this.income, placeholder: '输入金额' })
          .width('40%')
          .height(40)
          .type(1)  // 数字键盘
          .margin({ right: 10 })
          .onChange((value: string) => {
            this.income = value;
          });
        Button('添加')
          .width(80)
          .height(40)
          .backgroundColor('#4CAF50')
          .fontColor(Color.White)
          .onClick(() => {
            this.addRecord('收入', this.income);
          });
      }
      .margin({ bottom: 10 })

      // 支出输入
      Row() {
        Text('支出：')
          .fontSize(18)
          .width(60);
        TextInput({ text: this.expense, placeholder: '输入金额' })
          .width('40%')
          .height(40)
          .type(1)  // 数字键盘
          .margin({ right: 10 })
          .onChange((value: string) => {
            this.expense = value;
          });
        Button('添加')
          .width(80)
          .height(40)
          .backgroundColor('#FF5722')
          .fontColor(Color.White)
          .onClick(() => {
            this.addRecord('支出', this.expense);
          });
      }
      .margin({ bottom: 10 })

      // 备注输入
      Row() {
        Text('备注：')
          .fontSize(18)
          .width(60);
        TextInput({ text: this.remark, placeholder: '输入备注（可选）' })
          .width('60%')
          .height(40)
          .onChange((value: string) => {
            this.remark = value;
          });
      }
      .margin({ bottom: 20 })

      // 记录列表
      Text('记账记录 (' + this.records.length + '条)')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 10 });

      if (this.records.length === 0) {
        Column() {
          Text('暂无记录')
            .fontSize(16)
            .fontColor('#999999');
          Text('点击上面的按钮开始记账')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 5 });
        }
        .height(100)
        .justifyContent(FlexAlign.Center);
      } else {
        List() {
          ForEach(this.records, (item: AccountRecord, index: number) => {
            ListItem() {
              Row() {
                // 类型和金额
                Column() {
                  Text(item.type)
                    .fontSize(16)
                    .fontColor(item.type === '收入' ? '#008000' : '#FF0000');
                  Text('¥' + item.amount.toFixed(2))
                    .fontSize(18)
                    .fontColor(item.type === '收入' ? '#008000' : '#FF0000')
                    .margin({ top: 2 });
                }
                .width(100)

                // 备注
                Column() {
                  Text(item.remark)
                    .fontSize(16)
                    .fontColor('#333333');
                  Text(item.time)
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ top: 2 });
                }
                .layoutWeight(1)

                // 删除按钮
                Button('删除')
                  .width(60)
                  .height(30)
                  .fontSize(12)
                  .backgroundColor('#FFEBEE')
                  .fontColor('#FF5722')
                  .onClick(() => {
                    this.deleteRecord(index);
                  });
              }
              .padding(10)
              .width('100%')
              .backgroundColor(Color.White)
              .borderRadius(8)
              .margin({ bottom: 5 })
              .shadow({ radius: 2, color: '#0000000F', offsetX: 0, offsetY: 1 })
            }
          }, (item: AccountRecord) => item.time + item.amount + item.type)
        }
        .height(400)
      }
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor('#F8F9FA')
  }
}