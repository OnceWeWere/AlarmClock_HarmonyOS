export interface ReturnAlarmData {
  hour: string,
  minute: string,
  repeat: boolean,
  statutoryHoliday: boolean,
  alarmRingtone: Resource,
  alarmClockName: string,
  AlarmDuration: number,
  RepeatingInterval: number[], // 再响间隔：响铃间隔的时间，重复次数
  isOpen: boolean,
  reminderId?: number
}