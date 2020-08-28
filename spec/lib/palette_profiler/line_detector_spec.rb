RSpec.describe PaletteProfiler::LineDetector do
  before do
    allow(::File).to receive(:open).and_call_original
    allow(::File).to receive(:open).with(output_path, 'w').and_yield dst_io
  end

  let!(:dst_io) { ::StringIO.new('', 'w') }
  let!(:output_path) { 'output-path' }

  it 'output result csv file' do
    detector = described_class.new
    detector.start
    string = 'a' * 1000
    detector.stop
    detector.output output_path

    lines = dst_io.string.lines(chomp: true)
    expect(lines[0]).to eq %q{GC Generation,Memory Size (bytes)}
    # memory size list follows...
    expect(lines).to include %q{Source Location,Memory Size (bytes)}
    # memory size list follows...
  end
end
