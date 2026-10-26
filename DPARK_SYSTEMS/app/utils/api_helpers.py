import functools
import jwt
from datetime import datetime, timedelta, timezone
from flask import request, jsonify, g, current_app
from config import Config


def generate_token(user_id, peran):
    """Buat JWT untuk user (klaim: sub, peran, iat, exp)."""
    now = datetime.now(timezone.utc)
    payload = {
        'sub': str(int(user_id)),
        'peran': peran,
        'iat': now,
        'exp': now + timedelta(minutes=Config.JWT_EXPIRES_MINUTES),
    }
    return jwt.encode(payload, Config.JWT_SECRET_KEY, algorithm='HS256')


def decode_token(token):
    """Decode & validasi JWT. Raise jwt.PyJWTError bila tidak valid."""
    return jwt.decode(token, Config.JWT_SECRET_KEY, algorithms=['HS256'])


def _extract_token():
    auth = request.headers.get('Authorization', '')
    if auth.startswith('Bearer '):
        return auth[7:].strip()
    return None


def token_required(f):
    """Wajibkan header Authorization: Bearer <JWT>. Gagal -> 401 JSON."""

    @functools.wraps(f)
    def wrapper(*args, **kwargs):
        token = _extract_token()
        if not token:
            return jsonify({'status': 'gagal', 'pesan': 'Token tidak ditemukan. Silakan login.'}), 401
        try:
            payload = decode_token(token)
        except jwt.ExpiredSignatureError:
            return jsonify({'status': 'gagal', 'pesan': 'Token kedaluwarsa. Silakan login ulang.'}), 401
        except jwt.PyJWTError:
            return jsonify({'status': 'gagal', 'pesan': 'Token tidak valid. Silakan login ulang.'}), 401

        g.user = {
            'id_pengguna': int(payload.get('sub')),
            'peran': payload.get('peran'),
        }
        return f(*args, **kwargs)

    return wrapper


def pelanggan_required(f):
    """Wajibkan peran 'pelanggan'. Gagal -> 403 JSON. Pakai SETELAH @token_required."""

    @functools.wraps(f)
    def wrapper(*args, **kwargs):
        user = getattr(g, 'user', None)
        if not user or user.get('peran') != 'pelanggan':
            return jsonify({'status': 'gagal', 'pesan': 'Akses ditolak. Hanya untuk pelanggan.'}), 403
        return f(*args, **kwargs)

    return wrapper


def current_user_id():
    """Ambil id_pengguna dari token (harus setelah @token_required)."""
    return getattr(g, 'user', {}).get('id_pengguna')
