<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LoginController extends Controller
{
    public function login(Request $request)
    {
        if (Auth::attempt(['email' => $request->email, 'password' => $request->password])) {
            $user = Auth::user();
            $token = $user->createToken('app')->plainTextToken;

            return response()->json([
                'acceso' => "Ok",
                'error' => "",
                'token' => $token,
                'idUsuario' => $user->id,
                'nombreUsuario' => $user->name,
                'rol' => $user->rol
            ]);
        } else {
            return response()->json([
                'acceso' => "",
                'token' => "",
                'error' => "No existe el usuario y/o contraseña",
                'idUsuario' => 0,
                'nombreUsuario' => '',
                'rol' => ''
            ]);
        }
    }
}
