



import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:stripe_app/models/payments_intent_response.dart';
import 'package:stripe_app/models/srtripe_custom_response.dart';
import 'package:stripe_payment/stripe_payment.dart';

class StripeService {


  StripeService._priveteConstructor();
  static final StripeService _instance = StripeService._priveteConstructor();

  factory StripeService(){
    return _instance;
  }


  String _pymentApiUrl = 'https://api.stripe.com/v1/payment_intents';
  static final String _secretKey = 'sk_test_51HtzeALbQcxzhM8gozC3RjBmPE4nzb5nSz0QuF0fZFy3gZxfeiHUZ7cqbO2G7p7fVJx8nw606E74M9lF01KFy7w200NuQTKk2e';
  String _apiKey    = 'pk_test_51HtzeALbQcxzhM8gOG56iTJciSLoQ95uqUqB3FvPtEvgPoAhzEXQBflGqbya2gksK7x6fQOIHprjNxgxxt2kR4vW00tZK3Ulay';
  
  final headerOPtions = new Options(
    contentType: Headers.formUrlEncodedContentType,
    headers: {
      'Authorization': 'Bearer $_secretKey'
    }
  );
 
  void init(){
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: this._apiKey,
        androidPayMode: 'test',
        merchantId: 'test',

      )
    );
  }

  Future<StripeCustomResponse> pagarApplePayGooglePay({
    @required String amount,
    @required String currency,
  })async{

   try {
     final newAmount = double.parse(amount) /100;

    final token = await StripePayment.paymentRequestWithNativePay(
      androidPayOptions: AndroidPayPaymentRequest(
        currencyCode: currency, 
        totalPrice: amount
      ), 
      applePayOptions: ApplePayPaymentOptions(
        countryCode: 'US',
        currencyCode: currency,
        items: [
          ApplePayItem(
            label: 'SuperProducto 1',
            amount: '$newAmount'
          )
        ]
      )
    );



    final paymentMethod = await StripePayment.createPaymentMethod(
      PaymentMethodRequest(
        card: CreditCard(
          token: token.tokenId
        )
      )
    );

    final resp = await this._realizarPago(amount: amount, currency: currency, paymentMetod: paymentMethod);

    await StripePayment.completeNativePayRequest();

    return resp;
     
   } catch (e) {

      return StripeCustomResponse(
        ok: false,
        msg: e.toString()
     );

   }


  }

  Future<StripeCustomResponse> pagarConNuevaTarjeta({
    @required String amount,
    @required String currency,
  })async{
    try {
      final paymentMethod = await StripePayment.paymentRequestWithCardForm(
        CardFormPaymentRequest()
      );

      final resp = await this._realizarPago(amount: amount, currency: currency, paymentMetod: paymentMethod);

      return resp;


    } catch (e) {
      return StripeCustomResponse(ok: false, msg: e.toString());
    }
  }

  Future<StripeCustomResponse> pagarConTarjetaExistente({
    @required String amount,
    @required String currency,
    @required CreditCard card,
  })async{

    try {
      final paymentMethod = await StripePayment.createPaymentMethod(
        PaymentMethodRequest(card: card)
      );

      final resp = await this._realizarPago(amount: amount, currency: currency, paymentMetod: paymentMethod);

      return resp;

    } catch (e) {
      return StripeCustomResponse(ok: false, msg: e.toString());
    }

  }



  Future _crearPaymentIntent({
    @required String amount, 
    @required String currency,
    })async{

      try {
        final dio =  new Dio();
        final data = {
          'amount': amount,
          'currency': currency
        };
        final resp = await dio.post(
          _pymentApiUrl,
          data: data,
          options: headerOPtions
        );

        return PymentsIntentResponse.fromJson(resp.data);

      } catch (e) {
        print('Error en intent : ${e.toString()}');
        return PymentsIntentResponse(
          status: '400'
        );
      }

  } 

  Future<StripeCustomResponse> _realizarPago({
    @required String amount, 
    @required String currency,
    @required PaymentMethod paymentMetod,

  }) async{
    try {
    
      final paymentIntent = await this._crearPaymentIntent(amount: amount, currency: currency);

      final paymentResult = await StripePayment.confirmPaymentIntent(
        PaymentIntent(
          clientSecret: paymentIntent.clientSecret,
          paymentMethodId: paymentMetod.id
        )
      );

      if(paymentResult.status == 'succeeded'){
        return StripeCustomResponse(ok: true);
      }else{
        return StripeCustomResponse(ok: false, msg: 'Fallo: ${ paymentResult.status } ');
      }
      
    } catch (e) {

      return StripeCustomResponse(
        ok: false,
        msg: e.toString()
      );

    }

  } 

}