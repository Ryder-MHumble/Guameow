import 'package:flutter/material.dart';
import '../../../modules/style/app_theme.dart';

class CustomDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime) onDateSelected;

  const CustomDatePicker({
    super.key,
    this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late DateTime _selectedDate;
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;
  final int _currentYear = DateTime.now().year;
  final int _startYear = DateTime.now().year - 100; // 从100年前开始
  
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _selectedYear = _selectedDate.year;
    _selectedMonth = _selectedDate.month;
    _selectedDay = _selectedDate.day;
    
    // 初始化控制器，设置初始位置
    _yearController = FixedExtentScrollController(initialItem: _selectedYear - _startYear);
    _monthController = FixedExtentScrollController(initialItem: _selectedMonth - 1);
    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  void _updateSelectedDate() {
    // 检查日期是否有效，无效日期时做调整
    int daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    int validDay = _selectedDay > daysInMonth ? daysInMonth : _selectedDay;
    
    final newDate = DateTime(_selectedYear, _selectedMonth, validDay);
    if (newDate != _selectedDate) {
      setState(() {
        _selectedDate = newDate;
        _selectedDay = validDay;
      });
      
      // 如果日期变化导致日数变化，需要更新日期选择器
      if (_selectedDay != validDay && _dayController.hasClients) {
        try {
          _dayController.jumpToItem(validDay - 1);
        } catch (e) {
          // 忽略可能的越界错误
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.smallRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '选择日期',
                style: AppTheme.titleStyle.copyWith(fontSize: 16),
              ),
              Text(
                '${_selectedYear}年${_selectedMonth}月${_selectedDay}日',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                // 年份选择器
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                    ),
                    child: Stack(
                      children: [
                        ListWheelScrollView.useDelegate(
                          controller: _yearController,
                          itemExtent: 50,
                          perspective: 0.005,
                          diameterRatio: 1.5,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedYear = _startYear + index;
                              _updateSelectedDate();
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: _currentYear - _startYear + 1,
                            builder: (context, index) {
                              final year = _startYear + index;
                              final isSelected = year == _selectedYear;
                              return Center(
                                child: Text(
                                  '$year年',
                                  style: TextStyle(
                                    fontSize: isSelected ? 18 : 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected ? AppTheme.primary : Colors.black87,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // 中间指示器
                        Center(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: AppTheme.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                                bottom: BorderSide(
                                  color: AppTheme.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 月份选择器
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                    ),
                    child: Stack(
                      children: [
                        ListWheelScrollView.useDelegate(
                          controller: _monthController,
                          itemExtent: 50,
                          perspective: 0.005,
                          diameterRatio: 1.5,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedMonth = index + 1;
                              _updateSelectedDate();
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 12,
                            builder: (context, index) {
                              final month = index + 1;
                              final isSelected = month == _selectedMonth;
                              return Center(
                                child: Text(
                                  '$month月',
                                  style: TextStyle(
                                    fontSize: isSelected ? 18 : 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected ? AppTheme.primary : Colors.black87,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // 中间指示器
                        Center(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: AppTheme.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                                bottom: BorderSide(
                                  color: AppTheme.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 日期选择器
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                    ),
                    child: Stack(
                      children: [
                        ListWheelScrollView.useDelegate(
                          controller: _dayController,
                          itemExtent: 50,
                          perspective: 0.005,
                          diameterRatio: 1.5,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedDay = index + 1;
                              _updateSelectedDate();
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: DateTime(_selectedYear, _selectedMonth + 1, 0).day,
                            builder: (context, index) {
                              final day = index + 1;
                              final isSelected = day == _selectedDay;
                              return Center(
                                child: Text(
                                  '$day日',
                                  style: TextStyle(
                                    fontSize: isSelected ? 18 : 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected ? AppTheme.primary : Colors.black87,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // 中间指示器
                        Center(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: AppTheme.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                                bottom: BorderSide(
                                  color: AppTheme.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  '取消',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  widget.onDateSelected(_selectedDate);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                  ),
                ),
                child: const Text('确定'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
