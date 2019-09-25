<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/
use Illuminate\Http\Request;
use App\Penyakit;
use App\Gejala;
use App\GejalaPenyakit;

Route::get('/', function (Request $request) {
    error_log($request);
    return 'hello';
});

Route::get('/disease', function() {
    return Penyakit::all();
});

Route::post('/disease/{id}/destroy', function($id) {
    DB::transaction(function () use ($id) {
        $disease = Penyakit::find($id);
        $disease->gejala_penyakit()->delete();
        $disease->delete();
    });

    return collect(['error' => false]);
});

Route::post('/disease/create', function(Request $request) {
    DB::transaction(function () use ($request) {
        $penyakit = new Penyakit;
        $penyakit->nama = $request->nama;
        $penyakit->save();

        foreach($request->gejala as $g) {
            $gp = new GejalaPenyakit;
            $gp->penyakit_id = $penyakit->id;
            $gp->gejala_id = $g;
            $gp->save();
        }
    });

    return collect(['error' => false]);
});

Route::get('/disease/{id}', function($id) {
    $penyakit = Penyakit::find($id);
    $gejala = $penyakit->gejala->map(function($item, $key) {
        return $item->id;
    })->toArray();

    $gejalaAll = Gejala::all()->map(function($item, $key) use ($gejala) {
        return [
            'id' => $item->id,
            'pertanyaan' => $item->pertanyaan,
            'nama' => $item->nama,
            'checked' => in_array($item->id, $gejala),
        ];
    });

    return collect([
        'id' => $penyakit->id,
        'nama' => $penyakit->nama,
        'gejala' => collect($gejalaAll),
    ]);
});



Route::post('/disease/{id}', function(Request $request, $id) {
    DB::transaction(function () use ($request, $id) {
        $penyakit = Penyakit::find($id);
        $penyakit->nama = $request->nama;
        $penyakit->save();
    
        $penyakit->gejala_penyakit()->delete();
        foreach($request->gejala as $g) {
            $gp = new GejalaPenyakit;
            $gp->penyakit_id = $penyakit->id;
            $gp->gejala_id = $g;
            $gp->save();
        }
    });

    return collect(['error' => false]);
});

Route::post('/symptom/create', function(Request $request) {
    DB::transaction(function () use ($request) {
        $gejala = new Gejala;
        $gejala->nama = $request->nama;
        $gejala->pertanyaan = $request->pertanyaan;
        $gejala->save();
    });

    return collect(['error' => false]);
});

Route::post('/symptom/{id}/destroy', function($id) {
    DB::transaction(function () use ($id) {
        $symptom = Gejala::find($id);
        $symptom->gejala_penyakit()->delete();
        $symptom->delete();
    });

    return collect(['error' => false]);
});

Route::post('/symptom/{id}', function(Request $request, $id) {
    DB::transaction(function () use ($request, $id) {
        $gejala = Gejala::find($id);
        $gejala->nama = $request->nama;
        $gejala->pertanyaan = $request->pertanyaan;
        $gejala->save();
    });

    return collect(['error' => false]);
});

Route::get('/symptom/{id}', function(Request $request, $id) {
    return Gejala::find($id);
});

Route::get('/question', function() {
    return Gejala::all();
});

function laplaceSmoothing($xi, $n, $alpha = 1) {
    return ($xi + $alpha) / (1 + ($alpha * $n));
}

function inputMatchGejala($gejalaId, $userGejala, $gejalaPenyakit) {
    $gejalaInUser = in_array($gejalaId, $userGejala);
    $gejalaInPenyakit = in_array($gejalaId, $gejalaPenyakit);

    return ($gejalaInUser && $gejalaInPenyakit) or (!$gejalaInUser && !$gejalaInPenyakit);
}

function getPenyakitProbability($userGejala, $gejalaPenyakit, $jumlahGejala) {
    $gejalaSesuaiCount = collect(range(1, $jumlahGejala))->filter(function($value, $key) use ($userGejala, $gejalaPenyakit) {
        return inputMatchGejala($value, $userGejala, $gejalaPenyakit);
    })->count();

    $gejalaNotSesuaiCount = $jumlahGejala - $gejalaSesuaiCount;

    $result = pow(laplaceSmoothing(0, $jumlahGejala), $gejalaNotSesuaiCount);
    $result = $result * (pow(laplaceSmoothing(1, $jumlahGejala), $gejalaSesuaiCount));

    return $result;
}

function getAllPenyakitProbability($userGejala, $gejalaPenyakitAll, $jumlahPenyakit, $jumlahGejala) {
    $hasilPrediksi = [];
    foreach(range(0, $jumlahPenyakit - 1) as $i) {
        $prob = getPenyakitProbability($userGejala, $gejalaPenyakitAll[$i], $jumlahGejala);
        $hasilPrediksi[] = $prob;
    }

    return $hasilPrediksi;
}

function getMaxItemIndex($items) {
    $maxIndex = 0;
    $maxValue = 0;
    foreach($items as $key => $value) {
        if ($maxValue < $value) {
            $maxValue = $value;
            $maxIndex = $key;
        }
    }

    return $maxIndex;
}

function calculateProbability($data) {
    $userGejala = $data->filter(function($item, $key) {
        return $item['answer'];
    })->map(function($item, $key) {
        return $item['id'];
    })->toArray();


    $gejalaPenyakit = Penyakit::with(['gejala_penyakit'])->get();
    $gejalaPenyakit = $gejalaPenyakit->map(function($item, $key) {
        return $item->gejala_penyakit->map(function($i, $k) {
            return $i->gejala_id;
        })->toArray();
    })->toArray();

    $penyakit = Penyakit::select('nama')->get();

    $jumlahPenyakit = $penyakit->count();
    $jumlahGejala = Gejala::all()->count();

    $penyakit = $penyakit->map(function($item, $key) {
        return $item->nama;
    })->toArray();

    $hasilPrediksi = getAllPenyakitProbability($userGejala, $gejalaPenyakit, $jumlahPenyakit, $jumlahGejala);

    $maxIndex = getMaxItemIndex($hasilPrediksi);
    $diseaseResult = $penyakit[$maxIndex];
    $diseaseResultProb = $hasilPrediksi[$maxIndex];

    $otherDiseases = [];
    $otherDiseasesProb = [];
    unset($hasilPrediksi[$maxIndex]);

    foreach(range(1, 3) as $id) {
        $maxIndex = getMaxItemIndex($hasilPrediksi);
        $otherDiseases[] = $penyakit[$maxIndex];
        $otherDiseasesProb[] = strval($hasilPrediksi[$maxIndex]);

        unset($hasilPrediksi[$maxIndex]);
    }

    return [
        'diseaseResult' => $diseaseResult,
        'diseaseProb' => strval($diseaseResultProb),
        'otherDiseases' => $otherDiseases,
        'otherDiseasesProb' => $otherDiseasesProb,
    ];
}

Route::post('/calculate', function(Request $request) {
    $data = $request->input('data');
    return calculateProbability(collect($data));
});

Route::post('/login', function(Request $request) {
    $username = 'admin';
    $password = 'admin';

    error_log($request);

    if ($request->username === $username && $request->password === $password) {
        return response()->json([
            'error' => false,
        ], 200);
    }

    return response()->json([
        'error' => true,
    ], 400);
});