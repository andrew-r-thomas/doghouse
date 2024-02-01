use std::sync::Arc;

use cpal::traits::{DeviceTrait, HostTrait, StreamTrait};
use realfft::{num_complex::Complex, ComplexToReal, RealFftPlanner, RealToComplex};

fn main() -> Result<(), anyhow::Error> {
    let host = cpal::default_host();

    // set up stuff for computing autocorrelation
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
) {
    let shift = input.len();
    assert!(shift <= 1024);

    buffer.rotate_left(shift);

    buffer[(1024 - shift)..].copy_from_slice(input);

    let mut padded: [f32; 2048] = [0.0; 2048];
    padded[0..1024].copy_from_slice(buffer);

    let _ = forward.process(&mut padded, spectrum);
    spectrum.

    println!("input: {:?}\n", input);
    println!("buffer: {:?}\n", buffer);
}
