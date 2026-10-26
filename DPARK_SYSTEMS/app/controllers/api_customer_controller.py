from flask import Blueprint, request, jsonify, g
from werkzeug.security import check_password_hash, generate_password_hash
from app import mysql
from app.models import reservasi_model, pembayaran_model
from app.utils.api_helpers import token_required, pelanggan_required, current_user_id

api_customer_bp = Blueprint('api_customer', __name__)


def _dict_rows(cur):
    cols = [c[0] for c in cur.description]
    return [dict(zip(cols, row)) for row in cur.fetchall()]


# ======================================================
# WAHANA (detail — daftar memakai GET /api/wahana yang sudah ada)
# ======================================================
@api_customer_bp.route('/api/wahana/<int:id_wahana>', methods=['GET'])
@token_required
def wahana_detail(id_wahana):
    cur = None
    try:
        cur = mysql.connection.cursor()
        cur.execute(
            """SELECT id_wahana, nama_wahana, deskripsi, status_wahana
               FROM wahana WHERE id_wahana = %s""",
            (id_wahana,),
        )
        w = cur.fetchone()
        cur.close()
        if not w:
            return jsonify({'status': 'gagal', 'pesan': 'Wahana tidak ditemukan.'}), 404
        return jsonify({
            'status': 'sukses',
            'data': {
                'id_wahana': w[0],
                'nama_wahana': w[1],
                'deskripsi': w[2],
                'status_wahana': w[3],
                'gambar_url': f'/wahana/image/{w[0]}',
            },
        }), 200
    except Exception:
        if cur:
            cur.close()
        return jsonify({'status': 'gagal', 'pesan': 'Gagal memuat wahana.'}), 500


# ======================================================
# RESERVASI
# ======================================================
@api_customer_bp.route('/api/reservasi', methods=['GET'])
@token_required
@pelanggan_required
def reservasi_list():
    try:
        rows = reservasi_model.get_reservasi_by_user(current_user_id())
        out = []
        for r in rows:
            out.append({
                'id_reservasi': r.get('id_reservasi'),
                'total_harga': float(r.get('total_harga') or 0),
                'status_pembayaran': r.get('status_pembayaran'),
                'nama_wahana': r.get('nama_wahana'),
                'nama_sesi': r.get('nama_sesi'),
                'waktu_mulai': str(r.get('waktu_mulai')),
                'waktu_selesai': str(r.get('waktu_selesai')),
                'kuota': r.get('kuota'),
            })
        return jsonify({'status': 'sukses', 'data': out}), 200
    except Exception:
        return jsonify({'status': 'gagal', 'pesan': 'Gagal memuat reservasi.'}), 500


@api_customer_bp.route('/api/reservasi', methods=['POST'])
@token_required
@pelanggan_required
def reservasi_create():
    data = request.get_json(silent=True) or {}
    try:
        id_sesi = int(data.get('id_sesi'))
        jumlah_tiket = int(data.get('jumlah_tiket', 1))
    except (TypeError, ValueError):
        return jsonify({'status': 'gagal', 'pesan': 'Data tidak valid.'}), 400

    if jumlah_tiket < 1 or jumlah_tiket > 20:
        return jsonify({'status': 'gagal', 'pesan': 'Jumlah tiket harus 1-20.'}), 400

    id_pengguna = current_user_id()
    cur = None
    try:
        cur = mysql.connection.cursor()
        cur.execute(
            """SELECT s.kuota, s.harga, s.nama_sesi, s.waktu_mulai, w.nama_wahana
               FROM sesi s JOIN wahana w ON s.id_wahana = w.id_wahana
               WHERE s.id_sesi = %s""",
            (id_sesi,),
        )
        sesi = cur.fetchone()
        if not sesi:
            return jsonify({'status': 'gagal', 'pesan': 'Sesi tidak ditemukan.'}), 404
        if sesi[0] < jumlah_tiket:
            return jsonify({'status': 'gagal', 'pesan': 'Kuota sesi tidak mencukupi.'}), 409

        cur.execute(
            """SELECT t.id_tiket FROM tiket t
               JOIN reservasi r ON t.id_reservasi = r.id_reservasi
               WHERE r.id_pengguna=%s AND t.id_sesi=%s""",
            (id_pengguna, id_sesi),
        )
        if cur.fetchone():
            return jsonify({'status': 'gagal', 'pesan': 'Anda sudah memiliki reservasi untuk sesi ini.'}), 409
        cur.close()
        cur = None
    except Exception:
        if cur:
            cur.close()
        return jsonify({'status': 'gagal', 'pesan': 'Gagal memeriksa sesi.'}), 500

    new_id = reservasi_model.add_reservasi_return_id(id_pengguna, id_sesi, jumlah_tiket)
    if not new_id:
        return jsonify({'status': 'gagal', 'pesan': 'Gagal membuat reservasi. Coba lagi.'}), 500

    detail = reservasi_model.get_reservasi(new_id)
    return jsonify({
        'status': 'sukses',
        'pesan': 'Reservasi dibuat. Silakan lakukan pembayaran.',
        'data': {
            'id_reservasi': new_id,
            'total_harga': float(detail.get('total_harga') or 0),
            'status_pembayaran': detail.get('status_pembayaran'),
        },
    }), 201


@api_customer_bp.route('/api/reservasi/<int:id_reservasi>', methods=['GET'])
@token_required
@pelanggan_required
def reservasi_detail(id_reservasi):
    cur = None
    try:
        cur = mysql.connection.cursor()
        cur.execute(
            """SELECT r.id_reservasi, r.total_harga, r.status_pembayaran, r.kode_unik,
                      s.nama_sesi, s.waktu_mulai, s.waktu_selesai, w.nama_wahana
               FROM reservasi r
               JOIN tiket t ON t.id_reservasi = r.id_reservasi
               JOIN sesi s ON t.id_sesi = s.id_sesi
               JOIN wahana w ON s.id_wahana = w.id_wahana
               WHERE r.id_reservasi = %s AND r.id_pengguna = %s
               LIMIT 1""",
            (id_reservasi, current_user_id()),
        )
        res = cur.fetchone()
        if not res:
            return jsonify({'status': 'gagal', 'pesan': 'Reservasi tidak ditemukan.'}), 404

        cur.execute(
            """SELECT t.id_tiket, t.kode_tiket, t.status_tiket
               FROM tiket t WHERE t.id_reservasi = %s ORDER BY t.id_tiket""",
            (id_reservasi,),
        )
        tiket_rows = _dict_rows(cur)
        cur.close()
        cur = None

        return jsonify({
            'status': 'sukses',
            'data': {
                'id_reservasi': res[0],
                'total_harga': float(res[1] or 0),
                'status_pembayaran': res[2],
                'kode_unik': res[3],
                'nama_sesi': res[4],
                'waktu_mulai': str(res[5]),
                'waktu_selesai': str(res[6]),
                'nama_wahana': res[7],
                'tiket': tiket_rows,
            },
        }), 200
    except Exception:
        if cur:
            cur.close()
        return jsonify({'status': 'gagal', 'pesan': 'Gagal memuat detail reservasi.'}), 500


# ======================================================
# PEMBAYARAN
# ======================================================
@api_customer_bp.route('/api/pembayaran/<int:id_reservasi>', methods=['POST'])
@token_required
@pelanggan_required
def pembayaran_create(id_reservasi):
    data = request.get_json(silent=True) or {}
    metode = data.get('metode_pembayaran')
    jumlah = data.get('jumlah_bayar')

    if metode not in ('BANK', 'QRIS'):
        return jsonify({'status': 'gagal', 'pesan': 'Metode pembayaran tidak valid.'}), 400

    detail = reservasi_model.get_reservasi(id_reservasi)
    if not detail or detail.get('id_pengguna') != current_user_id():
        return jsonify({'status': 'gagal', 'pesan': 'Reservasi tidak ditemukan.'}), 404
    if detail.get('status_pembayaran') == 'selesai':
        return jsonify({'status': 'gagal', 'pesan': 'Reservasi sudah dibayar.'}), 409

    try:
        jumlah = int(jumlah)
    except (TypeError, ValueError):
        return jsonify({'status': 'gagal', 'pesan': 'Jumlah bayar tidak valid.'}), 400
    if jumlah != int(detail.get('total_harga') or 0):
        return jsonify({
            'status': 'gagal',
            'pesan': f"Jumlah bayar harus tepat {int(detail.get('total_harga') or 0)}.",
        }), 400

    try:
        result = pembayaran_model.add_pembayaran(
            id_reservasi, {'jumlah_bayar': jumlah, 'metode_pembayaran': metode}
        )
    except ValueError as e:
        return jsonify({'status': 'gagal', 'pesan': str(e)}), 400
    except Exception:
        return jsonify({'status': 'gagal', 'pesan': 'Gagal memproses pembayaran.'}), 500

    if not result:
        return jsonify({'status': 'gagal', 'pesan': 'Gagal memproses pembayaran.'}), 500

    return jsonify({
        'status': 'sukses',
        'pesan': 'Pembayaran berhasil.',
        'data': {
            'id_pembayaran': result.get('id_pembayaran'),
            'pdf_file': result.get('pdf_file'),
        },
    }), 201


# ======================================================
# PROFIL
# ======================================================
@api_customer_bp.route('/api/profil', methods=['GET'])
@token_required
@pelanggan_required
def profil_get():
    cur = None
    try:
        cur = mysql.connection.cursor()
        cur.execute(
            """SELECT id_pengguna, nama_pengguna, email, nomor_telepon, alamat_rumah
               FROM pengguna WHERE id_pengguna = %s""",
            (current_user_id(),),
        )
        u = cur.fetchone()
        cur.close()
        if not u:
            return jsonify({'status': 'gagal', 'pesan': 'Pengguna tidak ditemukan.'}), 404
        return jsonify({
            'status': 'sukses',
            'data': {
                'id_pengguna': u[0],
                'nama_pengguna': u[1],
                'email': u[2],
                'nomor_telepon': u[3],
                'alamat_rumah': u[4],
            },
        }), 200
    except Exception:
        if cur:
            cur.close()
        return jsonify({'status': 'gagal', 'pesan': 'Gagal memuat profil.'}), 500


@api_customer_bp.route('/api/profil', methods=['PUT'])
@token_required
@pelanggan_required
def profil_update():
    data = request.get_json(silent=True) or {}
    nama = (data.get('nama_pengguna') or '').strip()
    nomor = (data.get('nomor_telepon') or '').strip() or None
    alamat = (data.get('alamat_rumah') or '').strip() or None
    password = data.get('password')
    old_password = data.get('old_password')

    if not nama:
        return jsonify({'status': 'gagal', 'pesan': 'Nama wajib diisi.'}), 400

    id_pengguna = current_user_id()
    cur = None
    try:
        cur = mysql.connection.cursor()
        if password:
            if not old_password:
                return jsonify({'status': 'gagal', 'pesan': 'Password lama wajib diisi.'}), 400
            cur.execute("SELECT password_hash FROM pengguna WHERE id_pengguna=%s", (id_pengguna,))
            row = cur.fetchone()
            if not row or not check_password_hash(row[0], old_password):
                return jsonify({'status': 'gagal', 'pesan': 'Password lama salah.'}), 400
            if len(password) < 6:
                return jsonify({'status': 'gagal', 'pesan': 'Password baru minimal 6 karakter.'}), 400
            cur.execute(
                """UPDATE pengguna SET nama_pengguna=%s, nomor_telepon=%s, alamat_rumah=%s,
                   password_hash=%s WHERE id_pengguna=%s""",
                (nama, nomor, alamat, generate_password_hash(password), id_pengguna),
            )
        else:
            cur.execute(
                """UPDATE pengguna SET nama_pengguna=%s, nomor_telepon=%s, alamat_rumah=%s
                   WHERE id_pengguna=%s""",
                (nama, nomor, alamat, id_pengguna),
            )
        mysql.connection.commit()
        cur.close()
        return jsonify({'status': 'sukses', 'pesan': 'Profil berhasil diperbarui.'}), 200
    except Exception:
        if cur:
            cur.close()
        return jsonify({'status': 'gagal', 'pesan': 'Gagal memperbarui profil.'}), 500
