#![feature(portable_simd)]
pub mod yin;
use std::{array, intrinsics::sinf32, sync::Arc};

use cpal::traits::{DeviceTrait, HostTrait, StreamTrait};
use realfft::{num_complex::Complex, ComplexToReal, RealFftPlanner, RealToComplex};

// something to note, this is going to be tested as a guitar tuner,
// so the range of frequencies that we can detect are specific to that
// that is something to see in the tau min and max
fn main() -> Result<(), anyhow::Error> {
    let host = cpal::default_host();

    // set up stuff for computing autocorrelation
    // TODO consider storing buffer as a SIMD vector
    let mut buffer: [f32; 1024] = [0.0; 1024];
    let mut planner = RealFftPlanner::<f32>::new();
    let fft_forward: Arc<dyn RealToComplex<f32>> = planner.plan_fft_forward(2048);
    let fft_inverse: Arc<dyn ComplexToReal<f32>> = planner.plan_fft_inverse(2048);
    // TODO see if we can do this without vec or if using vec is even a problem
    let mut spectrum = fft_forward.make_output_vec();
    let mut output = fft_inverse.make_output_vec();

    // Set up the input device and stream with the default input config.
    let device = host
        .default_input_device()
        .expect("failed to find input device");

    println!("Input device: {}", device.name()?);

    let config = device
        .default_input_config()
        .expect("Failed to get default input config");
    println!("Default input config: {:?}", config);

    let sec_per_sample = 1 as f32 / config.sample_rate().0 as f32;

    let err_fn = move |err| {
        eprintln!("an error occurred on stream: {}", err);
    };

    let stream = device.build_input_stream(
        &config.into(),
        move |data, _: &_| {
            process(
                data,
                &mut buffer,
                &fft_forward,
                &fft_inverse,
                &mut spectrum,
                &mut output,
                sec_per_sample,
            )
        },
        err_fn,
        None,
    )?;

    stream.play()?;

    loop {}
}

fn process(
    input: &[f32],
    buffer: &mut [f32; 1024],
    forward: &Arc<dyn RealToComplex<f32>>,
    inverse: &Arc<dyn ComplexToReal<f32>>,
    spectrum: &mut Vec<Complex<f32>>,
    output: &mut Vec<f32>,
    sec_per_sample: f32,
) {
    let shift = input.len();
    assert!(shift <= 1024);

    buffer.rotate_left(shift);

    buffer[(1024 - shift)..].copy_from_slice(input);

    // TODO move this out of the process function so that we only allocate once (and not in the function)
    // TODO also rename this to something like scratch or buffer to know that it is basically a place to
    // store temorary shit
    let mut padded: [f32; 2048] = [0.0; 2048];
    padded[0..1024].copy_from_slice(buffer);

    let _ = forward.process(&mut padded, spectrum);

    // find power spectrum
    // TODO SIMD the shit outta this
    for i in 0..spectrum.len() {
        let s = spectrum[i];
        spectrum[i] = Complex {
            re: f32::powi(f32::abs(f32::sqrt((s.re * s.re) + (s.im * s.im))), 2),
            im: 0.0,
        }
    }

    let _ = inverse.process(spectrum, output);

    // TODO now we need to efficiently find the gap between the peaks, and convert this to hertz
    // TODO potentially convert this to yin since this might be simpler
    let mut max_idx = 0;
    for i in 1024..2048 {
        if output[i - 1] < output[i] && output[i + 1] < output[i] {
            max_idx = i;
            break;
        }
    }

    // find distance between middle and peak
    let diff = max_idx - 1024;
    let sec = sec_per_sample * diff as f32;
    let htz = 1.0 / sec;

    println!("htz: {:?}\n", htz);
}

// TODO this is very hard coded for now,
// I really don't know a good way yet to make this a nice to use library,
// I really would love something like comptime
const size: usize = 1024;
const tau_min: usize = 20;
const tau_max: usize = 512;
// TODO watch video again to see math definition of diff fn
fn yin(signal: &[f32]) {}
