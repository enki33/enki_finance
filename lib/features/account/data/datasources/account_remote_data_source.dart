import 'package:enki_finance/features/account/data/models/account_model.dart';
import 'package:enki_finance/features/account/data/models/credit_card_details_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AccountRemoteDataSource {
  Future<List<AccountModel>> getAccounts();
  Future<AccountModel> getAccountById(String id);
  Future<AccountModel> createAccount(AccountModel account);
  Future<AccountModel> updateAccount(AccountModel account);
  Future<void> deleteAccount(String id);
  Future<bool> hasTransactions(String accountId);

  Future<CreditCardDetailsModel> getCreditCardDetails(String accountId);
  Future<CreditCardDetailsModel> createCreditCardDetails(
      CreditCardDetailsModel details);
  Future<CreditCardDetailsModel> updateCreditCardDetails(
      CreditCardDetailsModel details);
  Future<void> deleteCreditCardDetails(String id);
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final SupabaseClient supabase;

  AccountRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<AccountModel>> getAccounts() async {
    final response =
        await supabase.from('account').select().order('created_at');

    return response
        .map<AccountModel>((json) => AccountModel.fromJson(json))
        .toList();
  }

  @override
  Future<AccountModel> getAccountById(String id) async {
    final response =
        await supabase.from('account').select().eq('id', id).single();

    return AccountModel.fromJson(response);
  }

  @override
  Future<AccountModel> createAccount(AccountModel account) async {
    final json = account.toJson();
    // Remove id field to let Supabase generate it
    json.remove('id');

    final response =
        await supabase.from('account').insert(json).select().single();

    return AccountModel.fromJson(response);
  }

  @override
  Future<AccountModel> updateAccount(AccountModel account) async {
    final response = await supabase
        .from('account')
        .update(account.toJson())
        .eq('id', account.id!)
        .select()
        .single();

    return AccountModel.fromJson(response);
  }

  @override
  Future<void> deleteAccount(String id) async {
    await supabase.from('account').delete().eq('id', id);
  }

  @override
  Future<bool> hasTransactions(String accountId) async {
    final response = await supabase
        .from('transaction')
        .select('id')
        .eq('account_id', accountId)
        .limit(1);

    return (response as List).isNotEmpty;
  }

  @override
  Future<CreditCardDetailsModel> getCreditCardDetails(String accountId) async {
    final response = await supabase
        .from('credit_card_details')
        .select()
        .eq('account_id', accountId)
        .single();

    return CreditCardDetailsModel.fromJson(response);
  }

  @override
  Future<CreditCardDetailsModel> createCreditCardDetails(
      CreditCardDetailsModel details) async {
    final response = await supabase
        .from('credit_card_details')
        .insert(details.toJson())
        .select()
        .single();

    return CreditCardDetailsModel.fromJson(response);
  }

  @override
  Future<CreditCardDetailsModel> updateCreditCardDetails(
      CreditCardDetailsModel details) async {
    final response = await supabase
        .from('credit_card_details')
        .update(details.toJson())
        .eq('id', details.id!)
        .select()
        .single();

    return CreditCardDetailsModel.fromJson(response);
  }

  @override
  Future<void> deleteCreditCardDetails(String id) async {
    await supabase.from('credit_card_details').delete().eq('id', id);
  }
}
