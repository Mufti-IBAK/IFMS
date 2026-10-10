import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

Future<DateTime?> showResponsiveCalendarPicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  firstDate ??= DateTime(2020);
  lastDate ??= DateTime(2100);

  return showDialog<DateTime>(
    context: context,
    builder: (dialogCtx) {
      return ResponsiveCalendarDialog(
        initialDate: initialDate,
        firstDate: firstDate!,
        lastDate: lastDate!,
      );
    },
  );
}

class ResponsiveCalendarDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const ResponsiveCalendarDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<ResponsiveCalendarDialog> createState() => _ResponsiveCalendarDialogState();
}

class _ResponsiveCalendarDialogState extends State<ResponsiveCalendarDialog> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(widget.initialDate.year, widget.initialDate.month, 1);
    _selectedDate = DateTime(widget.initialDate.year, widget.initialDate.month, widget.initialDate.day);
  }

  void _previousMonth() {
    final prev = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    if (!prev.isBefore(DateTime(widget.firstDate.year, widget.firstDate.month, 1))) {
      setState(() {
        _focusedMonth = prev;
      });
    }
  }

  void _nextMonth() {
    final next = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    if (!next.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month, 1))) {
      setState(() {
        _focusedMonth = next;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstDayOfWeek = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 320,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Month Header & Navigation Chevrons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: AppColors.primary, size: 24),
                  onPressed: _previousMonth,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedMonth),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: AppColors.primary, size: 24),
                  onPressed: _nextMonth,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Weekday Headers (S M T W T F S)
            Row(
              children: weekdays.map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
            Divider(height: 1, color: Colors.grey.shade300),
            const SizedBox(height: 6),

            // Grid of Days (7 Columns, Fixed Cell Aspect Ratio)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: firstDayOfWeek + daysInMonth,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                if (index < firstDayOfWeek) {
                  return const SizedBox.shrink();
                }
                final dayNumber = index - firstDayOfWeek + 1;
                final cellDate = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);

                final isSelected = cellDate.year == _selectedDate.year &&
                    cellDate.month == _selectedDate.month &&
                    cellDate.day == _selectedDate.day;

                final isTodayCell = cellDate.year == today.year &&
                    cellDate.month == today.month &&
                    cellDate.day == today.day;

                final isSelectable = !cellDate.isBefore(DateTime(widget.firstDate.year, widget.firstDate.month, widget.firstDate.day)) &&
                    !cellDate.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month, widget.lastDate.day));

                return InkWell(
                  onTap: isSelectable
                      ? () {
                          setState(() {
                            _selectedDate = cellDate;
                          });
                          Navigator.pop(context, cellDate);
                        }
                      : null,
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : isTodayCell
                              ? Colors.teal.shade50
                              : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isTodayCell && !isSelected
                          ? Border.all(color: AppColors.primary, width: 1.5)
                          : null,
                    ),
                    child: Text(
                      '$dayNumber',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected || isTodayCell ? FontWeight.bold : FontWeight.normal,
                        color: !isSelectable
                            ? Colors.grey.shade300
                            : isSelected
                                ? Colors.white
                                : isTodayCell
                                    ? AppColors.primary
                                    : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade300),
            const SizedBox(height: 6),

            // Bottom Actions: TODAY & CANCEL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.today, size: 16, color: AppColors.primary),
                  label: const Text('TODAY', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12)),
                  onPressed: () {
                    Navigator.pop(context, today);
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
