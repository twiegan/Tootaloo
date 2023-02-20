import 'package:firebase_auth/firebase_auth.dart';


class AuthenticationService{
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  Stream get authStateChanges => _firebaseAuth.userChanges();


  Future<void> signOut() async{
    await _firebaseAuth.signOut();
  }

  Future<int> signIn({required String email, required String password}) async{
    try{
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return 1;

    } on FirebaseAuthException catch (e){
      var errorCode = e.code;
      var errorMessage = e.message;


      if(errorCode == 'auth/wrong-password'){
        return (0);
      }
      else{
        return -1;
      }
    }

  }

  Future<String?> signUp({required String email, required String password}) async{
    try{
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return "Signed up";
    } on FirebaseAuthException catch(e){
      return e.message;
    }
  }


}