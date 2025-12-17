import 'package:mobx/mobx.dart';

part 'rsvp_store.g.dart';

// ignore: library_private_types_in_public_api
class RsvpStore = _RsvpStore with _$RsvpStore;

abstract class _RsvpStore with Store {
  @observable
  String nome = '';

  @observable
  String telefone = '';

  @observable
  bool confirmado = false;

  @observable
  int numeroPessoas = 1;

  @action
  void setNome(String value) => nome = value;

  @action
  void setTelefone(String value) => telefone = value;

  @action
  void setConfirmado(bool value) => confirmado = value;

  @action
  void setNumeroPessoas(int value) => numeroPessoas = value;


  @action
  void limpar() {
    nome = '';
    telefone = '';
    confirmado = false;
    numeroPessoas = 1;
  }

  @computed
  bool get formularioValido => nome.isNotEmpty && telefone.isNotEmpty;
}
