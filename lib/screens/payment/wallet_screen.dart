import 'package:bay_yahe_app/screens/payment/Transaction_screen.dart';
import 'package:bay_yahe_app/screens/payment/widgets/cash_in.dart';
import 'package:bay_yahe_app/screens/payment/widgets/payment_method.dart';
import 'package:flutter/material.dart';
import 'package:bay_yahe_app/screens/payment/widgets/action_button.dart';
import 'package:bay_yahe_app/screens/payment/widgets/info_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF33c072),
        title: const Center(
          child: Text(
            'Wallet',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const InfoCard(),
                  const SizedBox(height: 10),
                  Center(
                    child: SizedBox(
                      height: 100,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ActionButton(
                              title: "Pay",
                              icon: FontAwesomeIcons.creditCard,
                              onpress: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PaymentMethods(),
                                  ),
                                );
                              },
                            ),
                            ActionButton(
                              title: "Cash-In",
                              icon: FontAwesomeIcons.plusCircle,
                              onpress: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CashInOptions(),
                                  ),
                                );
                              },
                            ),
                            ActionButton(
                              title: "Transaction",
                              icon: FontAwesomeIcons.exchangeAlt,
                              onpress: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Transaction(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
