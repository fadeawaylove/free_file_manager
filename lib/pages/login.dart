import 'package:flutter/material.dart';
import 'package:free_file_manager/apis/gitee_api.dart';

class LoginPage extends StatefulWidget {
  static String routeName = "/login";
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? giteeToken;

  Future submitForm() async {
    ScaffoldMessenger.of(context).clearSnackBars();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      GiteeApi.getUserInfo(inputToken: giteeToken).then((value) {
        if (value == null) {
          // 登录失败
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('登录失败，请检查输入'),
              duration: Duration(milliseconds: 1200),
            ),
          );
        } else {
          // 登录成功
          debugPrint("登陆成功: ${value.userInfo}");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('登录成功'),
              duration: Duration(milliseconds: 1500),
            ),
          );
          Navigator.pushNamed(context, "/home", arguments: value);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("欢迎登录FCF管理器"),
      ),
      body: Center(
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 300,
                    child: TextFormField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.token),
                        border: OutlineInputBorder(),
                        hintText: "输入gitee私人令牌",
                      ),
                      onSaved: (inputToken) {
                        giteeToken = inputToken;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "搞咩啊，输空的玩我？";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    style: ButtonStyle(
                      textStyle: MaterialStateProperty.all(
                          const TextStyle(fontSize: 20)),
                      // minimumSize: MaterialStateProperty.all(Size(200, 100))
                    ),
                    child: const Text("登录"),
                    onPressed: () => submitForm(),
                  ),
                ],
              ))),
    );
  }
}
