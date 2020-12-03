import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stripe_app/bloc/pagar/pagar_bloc.dart';
import 'package:stripe_app/helpers/helpers.dart';
import 'package:stripe_app/services/stripe_service.dart';
import 'package:stripe_payment/stripe_payment.dart';



class TotalPayBotton extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {
    final pagarBloc = context.watch<PagarBloc>().state;

    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      width: width,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30)
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Total', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              Text('${pagarBloc.montoAPgar} ${pagarBloc.moneda}', style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400)),
            ],
          ),

          BlocBuilder<PagarBloc, PagarState>(
            builder: (context, state) {
              return _BtnPay(state,);
            },
          )

          
        
        ],  
      ),
    );
  }
}

class _BtnPay extends StatelessWidget {
  
  final PagarState state;

  const _BtnPay( this.state) ;

  @override
  Widget build(BuildContext context) {
    return state.tarjetaActiva
    ? builButtonTarjeta(context)
    : builAplleAndGooglePay(context);
  }


  Widget builButtonTarjeta(BuildContext context) {
    return MaterialButton(
      height: 45,
      minWidth: 170,
      shape: StadiumBorder(),
      elevation: 0,
      color: Colors.black,
      child: Row(
        children: [
           Icon(FontAwesomeIcons.solidCreditCard,color: Colors.white,),
          
          Text('   Pagar', style: TextStyle(color: Colors.white, fontSize: 22),),
        ],
      ),
      onPressed: () async {

         mostrarLoading(context);
        
        final stripeService = new StripeService();
        final pagarBloc = context.read<PagarBloc>().state;
        final tarjeta = pagarBloc.tarjeta;
        final mesAnio = tarjeta.expiracyDate.split('/');
        
        final resp = await stripeService.pagarConTarjetaExistente(
          amount: pagarBloc.montoPagarString, 
          currency: pagarBloc.moneda, 
          card: CreditCard(
            number: tarjeta.cardNumber,
            expMonth: int.parse(mesAnio[0]) ,
            expYear: int.parse(mesAnio[1])
          )
        );

         Navigator.pop(context);

        if(resp.ok){
          mostrarAlerta(context, 'Tarjeta ok', 'Todo correcto');
        }else{
          mostrarAlerta(context, 'Algo salio mal', resp.msg);
        }



      },
    );
  }
  
  Widget builAplleAndGooglePay(BuildContext context) {
    return MaterialButton(
      height: 45,
      minWidth: 150,
      shape: StadiumBorder(),
      elevation: 0,
      color: Colors.black,
      child: Row(
        children: [
          Platform.isAndroid
          ? Icon(FontAwesomeIcons.google,color: Colors.white,)
          : Icon(FontAwesomeIcons.apple,color: Colors.white,),
          
          Text('    Pay', style: TextStyle(color: Colors.white, fontSize: 22),),
        ],
      ),
      onPressed: () async {
        
        final stripeService = new StripeService();
        final state = context.read<PagarBloc>().state;

        final resp = await stripeService.pagarApplePayGooglePay(
          amount: state.montoPagarString, 
          currency: state.moneda
        );

      },
    );
  }
}