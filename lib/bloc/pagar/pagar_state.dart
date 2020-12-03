part of 'pagar_bloc.dart';

@immutable
class PagarState {

  final double montoAPgar;
  final String moneda;
  final bool tarjetaActiva;
  final TarjetaCredito tarjeta;


  String get montoPagarString => '${ (this.montoAPgar * 100 ).floor() }';

  PagarState({
    this.montoAPgar = 375.75, 
    this.moneda = 'USD', 
    this.tarjetaActiva = false, 
    this.tarjeta
  });

  PagarState copyWith({
    double montoAPgar,
    String moneda,
    bool tarjetaActiva,
    TarjetaCredito tarjeta,
  }) => PagarState(
    montoAPgar   : montoAPgar ?? this.montoAPgar,
    moneda       : moneda ?? this.moneda,
    tarjetaActiva: tarjetaActiva ?? this.tarjetaActiva,
    tarjeta      : tarjeta ?? this.tarjeta,
  );

}
