from flask import Blueprint, request, jsonify
from werkzeug.security import check_password_hash, generate_password_hash
from app import mysql
from app.utils.api_helpers import generate_token, token_required, current_user_id

api_auth_bp = Blueprint('api_auth', __name__)


@api_auth_bp.route('/api/register', methods=['POST'])
def register_pelanggan():
    data = request.get_json(silent=True) or {}

    nama = (data.get('nama_pengguna') or '').strip()
    email = (data.get('email') or '').strip().lower()
    password = data.get('password') or ''
    nomor = (data.get('nomor_telepon') or '').strip() or None
    alamat = (data.get('alamat_rumah') or '').strip() or None

    if not nama or not email or not password:
        return jsonify({'status': 'gagal', 'pesan': 'Nama, email, dan password wajib diisi.'}), 400
    if len(password) < 6:
        return jsonify({'status': 'gagal', 'pesan': 'Password minimal 6 karakter.'}), 400
    if '@' not in email:
        return jsonify({'status': 'gagal', 'pesan': 'Format email tidak valid.'}), 400

    cur = None
    try:
        cur = mysql.connection.cursor()
        cur.execute("SELECT id_pengguna FROM pengguna WHERE email=%s", (email,))
        if cur.fetchone():
            return jsonify({'status': 'gagal', 'pesan': 'Email sudah terdaftar.'}), 409

        cur.execute(
            """INSERT INTO pengguna (nama_pengguna, email, password_hash, peran, nomor_telepon, alamat_rumah)
               VALUES (%s, %s, %s, 'pelanggan', %s, %s)""",
            (nama, email, generate_password_hash(password), nomor, alamat),
        )
        mysql.connection.commit()
        user_id = cur.lastrowid
        cur.close()
    except Exception:
        if cur:
            cur.close()
        return jsonify({'status': 'gagal', 'pesan': 'Gagal mendaftar. Coba lagi nanti.'}), 500

    token = generate_token(user_id, 'pelanggan')
    return jsonify({
        'status': 'sukses',
        'pesan': 'Registrasi berhasil.',
        'token': token,
        'data': {
            'id_pengguna': user_id,
            'nama_pengguna': nama,
            'email': email,
            'peran': 'pelanggan',
            'nomor_telepon': nomor,
            'alamat_rumah': alamat,
        },
    }), 201


@api_auth_bp.route('/api/login', methods=['POST'])
def login_pelanggan():
    data = request.get_json(silent=True) or {}
    email = (data.get('email') or '').strip().lower()
    password = data.get('password') or ''

    if not email or not password:
        return jsonify({'status': 'gagal', 'pesan': 'Email dan password wajib diisi.'}), 400

    cur = None
    try:
        cur = mysql.connection.cursor()
        cur.execute(
            """SELECT id_pengguna, nama_pengguna, email, password_hash, peran, nomor_telepon, alamat_rumah
               FROM pengguna WHERE email=%s""",
            (email,),
        )
        user = cur.fetchone()
        cur.close()
    except Exception:
        if cur:
            cur.close()
        return jsonify({'status': 'gagal', 'pesan': 'Gagal terhubung ke server.'}), 500

    if not user or not check_password_hash(user[3], password):
        return jsonify({'status': 'gagal', 'pesan': 'Email atau password salah.'}), 401

    peran = (user[4] or '').strip().lower()
    if peran != 'pelanggan':
        return jsonify({'status': 'gagal', 'pesan': 'Akun ini bukan akun pelanggan. Gunakan aplikasi web.'}), 403

    token = generate_token(user[0], peran)
    return jsonify({
        'status': 'sukses',
        'pesan': 'Login berhasil.',
        'token': token,
        'data': {
            'id_pengguna': user[0],
            'nama_pengguna': user[1],
            'email': user[2],
            'peran': peran,
            'nomor_telepon': user[5],
            'alamat_rumah': user[6],
        },
    }), 200


@api_auth_bp.route('/api/me', methods=['GET'])
@token_required
def me():
    cur = None
    try:
        cur = mysql.connection.cursor()
        cur.execute(
            """SELECT id_pengguna, nama_pengguna, email, peran, nomor_telepon, alamat_rumah
               FROM pengguna WHERE id_pengguna=%s""",
            (current_user_id(),),
        )
        user = cur.fetchone()
        cur.close()
    except Exception:
        if cur:
            cur.close()
        return jsonify({'status': 'gagal', 'pesan': 'Gagal memuat profil.'}), 500

    if not user:
        return jsonify({'status': 'gagal', 'pesan': 'Pengguna tidak ditemukan.'}), 404

    return jsonify({
        'status': 'sukses',
        'data': {
            'id_pengguna': user[0],
            'nama_pengguna': user[1],
            'email': user[2],
            'peran': user[3],
            'nomor_telepon': user[4],
            'alamat_rumah': user[5],
        },
    }), 200
