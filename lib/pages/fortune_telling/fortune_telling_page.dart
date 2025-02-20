import 'package:flutter/material.dart';
import '../../modules/style/app_theme.dart';

class FortuneTellingPage extends StatefulWidget {
  const FortuneTellingPage({Key? key}) : super(key: key);

  @override
  State<FortuneTellingPage> createState() => _FortuneTellingPageState();
}

class _FortuneTellingPageState extends State<FortuneTellingPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _birthDate;
  String? _bloodType;
  
  final List<String> _bloodTypes = ['A', 'B', 'O', 'AB'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _birthDate != null && _bloodType != null) {
      // TODO: 调用大模型API进行占卜
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    '喵咪占卜',
                    style: AppTheme.titleStyle.copyWith(fontSize: 28),
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  '选择生辰',
                  style: AppTheme.titleStyle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                      boxShadow: [AppTheme.softShadow],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _birthDate == null
                              ? '请选择日期'
                              : '${_birthDate!.year}年${_birthDate!.month}月${_birthDate!.day}日',
                          style: AppTheme.bodyStyle,
                        ),
                        Icon(Icons.calendar_today, color: AppTheme.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  '选择血型',
                  style: AppTheme.titleStyle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                    boxShadow: [AppTheme.softShadow],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _bloodType,
                      hint: Text('请选择血型', style: AppTheme.bodyStyle),
                      items: _bloodTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type, style: AppTheme.bodyStyle),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _bloodType = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                      ),
                    ),
                    child: Text(
                      '开始占卜',
                      style: AppTheme.titleStyle.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
