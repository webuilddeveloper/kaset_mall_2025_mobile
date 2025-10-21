import 'package:flutter/material.dart';

class AgricultureLoanPage extends StatefulWidget {
  const AgricultureLoanPage({super.key});

  @override
  State<AgricultureLoanPage> createState() => _AgricultureLoanPageState();
}

class _AgricultureLoanPageState extends State<AgricultureLoanPage> {
  double _loanAmount = 50000;
  int _selectedMonths = 12;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.04; // responsive padding

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.3,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 20, color: Theme.of(context).primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'สินเชื่อเพื่อการเกษตร',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(padding),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF09665a), Color(0xFF0d7f77)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.12),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                        child: Icon(
                          Icons.account_balance_outlined,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'สินเชื่อเกษตรกรรม',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'อนุมัติรวดเร็ว  •  ดอกเบี้ยต่ำ  •  เอกสารง่าย',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Loan Calculator Card
              _buildCard(
                padding,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(Icons.calculate, 'คำนวณวงเงินกู้'),
                    SizedBox(height: 20),
                    _buildLabel('จำนวนเงินที่ต้องการกู้'),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        '฿${_loanAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    Slider(
                      value: _loanAmount,
                      min: 10000,
                      max: 500000,
                      divisions: 49,
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor:
                          Theme.of(context).primaryColor.withOpacity(0.15),
                      onChanged: (value) => setState(() => _loanAmount = value),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('฿10,000',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF9ca3af))),
                        Text('฿500,000',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF9ca3af))),
                      ],
                    ),
                    SizedBox(height: 22),
                    _buildLabel('ระยะเวลาผ่อนชำระ (เดือน)'),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        _buildMonthOption(6),
                        SizedBox(width: 10),
                        _buildMonthOption(12),
                        SizedBox(width: 10),
                        _buildMonthOption(24),
                        SizedBox(width: 10),
                        _buildMonthOption(36),
                      ],
                    ),
                    SizedBox(height: 24),
                    _buildSummary(),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Requirements
              _buildCard(
                padding,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                        Icons.verified_outlined, 'คุณสมบัติผู้กู้'),
                    SizedBox(height: 16),
                    _buildRequirement('อายุ 20-65 ปี'),
                    _buildRequirement('ประกอบอาชีพเกษตรกรรม'),
                    _buildRequirement('มีรายได้ประจำ'),
                    _buildRequirement('มีบัญชีธนาคาร'),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Documents
              _buildCard(
                padding,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                        Icons.description_outlined, 'เอกสารที่ต้องใช้'),
                    SizedBox(height: 16),
                    _buildRequirement('สำเนาบัตรประชาชน'),
                    _buildRequirement('สำเนาทะเบียนบ้าน'),
                    _buildRequirement('หลักฐานการประกอบอาชีพ'),
                    _buildRequirement('สลิปเงินเดือน (ถ้ามี)'),
                  ],
                ),
              ),

              SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: _showApplicationDialog,
            icon: Icon(Icons.send, size: 18),
            label: Text(
              'สมัครสินเชื่อตอนนี้',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(double padding, Widget child) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: padding),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1a1a1a),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: Color(0xFF6b7280),
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildMonthOption(int months) {
    bool isSelected = _selectedMonths == months;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMonths = months),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color:
                isSelected ? Theme.of(context).primaryColor : Color(0xFFf3f4f6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Color(0xFFe5e7eb),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              '$months',
              style: TextStyle(
                color: isSelected ? Colors.white : Color(0xFF6b7280),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: Theme.of(context).primaryColor.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('อัตราดอกเบี้ยต่อปี', '5.99%'),
          Divider(
              height: 16,
              color: Theme.of(context).primaryColor.withOpacity(0.1)),
          _buildSummaryRow(
            'ยอดผ่อนชำระต่อเดือน',
            '฿${(_loanAmount / _selectedMonths * 1.0599).toStringAsFixed(0)}',
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF4b5563),
              fontWeight: FontWeight.w600,
            )),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 18 : 14,
            fontWeight: FontWeight.w600,
            color: isHighlight
                ? Theme.of(context).primaryColor
                : Color(0xFF1a1a1a),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(Icons.check_circle,
              color: Theme.of(context).primaryColor, size: 16),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF4b5563),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showApplicationDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle,
                  color: Theme.of(context).primaryColor, size: 52),
              SizedBox(height: 20),
              Text(
                'ส่งคำขอสำเร็จ',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1a1a1a)),
              ),
              SizedBox(height: 10),
              Text(
                'เจ้าหน้าที่จะติดต่อกลับภายใน 24 ชั่วโมง',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: Color(0xFF6b7280), height: 1.4),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child:
                    Text('ตกลง', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
