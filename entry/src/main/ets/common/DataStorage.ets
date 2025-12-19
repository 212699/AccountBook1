// entry/src/main/ets/common/DataStorage.ets
import dataPreferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

export class DataStorage {
  private pref: dataPreferences.Preferences | null = null;
  private ctx: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.ctx = context;
  }

  private async init(): Promise<void> {
    if (!this.pref) {
      this.pref = await dataPreferences.getPreferences(this.ctx, 'AccountBook');
    }
  }

  async save(key: string, value: string): Promise<void> {
    await this.init();
    if (this.pref) {
      await this.pref.put(key, value);
      await this.pref.flush();
    }
  }

  async get(key: string): Promise<string | null> {
    await this.init();
    if (this.pref) {
      const result = await this.pref.get(key, '');
      if (typeof result === 'string') {
        return result === '' ? null : result;
      }
      return null;
    }
    return null;
  }
}