<?php

namespace App;

use Illuminate\Database\Eloquent\Model;
use App\Penyakit;
use App\GejalaPenyakit;

class Gejala extends Model
{
    protected $table = 'gejala';
    public $timestamps = false;

    public function penyakit() {
        return $this->belongsToMany(Penyakit::classs, 'gejala_penyakit', 'gejala_id', 'penyakit_id');
    }

    public function gejala_penyakit() {
        return $this->hasMany(GejalaPenyakit::class, 'gejala_id', 'id');
    }
}
