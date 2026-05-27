import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

export class PreferencesUtil {
  private static instance: PreferencesUtil;
  private dataPreferences: preferences.Preferences | null = null;
  public static readonly STORE_NAME: string = 'app_preferences'; // 静态属性
  public static defaultValue: preferences.ValueType = []; // 空数组，默认值

  private constructor() {
  } // 私有构造函数（防止别人 new PreferencesUtil()）

  // 单例模式：确保一个类在整个程序运行期间只能创建一个对象实例，并且提供一个全局访问点来获取这个实例
  public static getInstance(): PreferencesUtil { // 静态方法
    if (!PreferencesUtil.instance) {
      PreferencesUtil.instance = new PreferencesUtil();
    }
    return PreferencesUtil.instance;
  }

  // 初始化（在 EntryAbility 中调用）
  public init(context: common.UIAbilityContext): void { // 实例方法
    // 获取 Preferences 实例
    let options: preferences.Options = { name: PreferencesUtil.STORE_NAME, storageType: preferences.StorageType.XML };
    this.dataPreferences = preferences.getPreferencesSync(context, options);

    // 订阅数据变更
    this.dataPreferences.on('change', (key: string) => {
      console.info(`[Preferences] Key '${key}' 已变更`);
    });
  }

  // 保存数据
  public put(key: string, value: preferences.ValueType): void {
    if (!this.dataPreferences) {
      console.info('The key startup is contained.')
      return;
    }
    this.dataPreferences.putSync(key, value);

    this.dataPreferences.flush(); // 持久化到文件
  }

  // 获取数据
  public get(key: string, defaultValue: preferences.ValueType): preferences.ValueType {
    if (!this.dataPreferences) {
      return defaultValue;
    }
    return this.dataPreferences.getSync(key, defaultValue);
  }

  // 删除数据
  public delete(key: string): void {
    if (!this.dataPreferences) {
      return;
    }
    this.dataPreferences.deleteSync(key);
    this.dataPreferences.flush();
  }

  // 检查 Key 是否存在
  public has(key: string): boolean {
    if (!this.dataPreferences) {
      return false;
    }
    return this.dataPreferences.hasSync(key);
  }

  // 清空所有数据
  public clear(): void {
    if (!this.dataPreferences) {
      return;
    }
    this.dataPreferences.clearSync();
    this.dataPreferences.flush();
  }

  // 获取所有数据
  public getAll(): Record<string, preferences.ValueType> {
    /* Record 类型通常写作 Record<K, T>，其中 K表示属性键（key）的类型，T表示属性值（value）的类型。该工具类型可将一种类型的属性映射到另一种类型，从而在编译时提供明确的类型约束。
    * 其主要特点包括：
    字段固定：一旦定义，其包含的字段（属性）是固定的，不能像 Map 那样随意添加或删除键值对。
    轻量简洁：相比完整的类定义，Record 的语法更简洁，适合快速定义数据结构。
    类型安全：在编译阶段即可检查字段名称和值的类型，避免运行时错误。
    直接访问：字段通常通过点符号（.）直接访问，代码可读性高。*/
    if (!this.dataPreferences) {
      return {};
    }
    return this.dataPreferences.getAllSync() as Record<string, preferences.ValueType>;
  }
}

// 导出单例实例
export default PreferencesUtil.getInstance();
// export const preferencesUtil = PreferencesUtil.getInstance();
