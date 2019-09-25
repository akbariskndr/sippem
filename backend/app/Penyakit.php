<?php

namespace App;

use Illuminate\Database\Eloquent\Model;
use App\GejalaPenyakit;
use App\Gejala;

class Penyakit extends Model
{
    protected $table = 'penyakit';
    public $timestamps = false;

    public function gejala_penyakit() {
        return $this->hasMany(GejalaPenyakit::class, 'penyakit_id', 'id');
    }

    public function gejala() {
        return $this->belongsToMany(Gejala::class, 'gejala_penyakit', 'penyakit_id', 'gejala_id');
    }
}
