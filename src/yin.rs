use std::{array, simd::f32x4};

struct Yin<const size: usize>{
    threshold: f32,
    tau_max: usize,
    tau_min: usize,
    sample_rate: usize,
}

// TODO, maybe think about how to do this more elegantly
impl Yin<1024>{

    pub fn detect_pitch(tau_max: const usize, signal: &[f32]) -> f32 {
        let true_max = std::cmp::min(self.tau_max, signal.len());

        let temp: [f32; self.size - true_max] =
            array::from_fn(|i| signal[i] - signal[i - true_max]);

        0.0
    }
}
