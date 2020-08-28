RSpec.describe PaletteProfiler::ObjectCounter do
  before do
    allow(::File).to receive(:open).and_call_original
    allow(::File).to receive(:open).with(output_path, 'w').and_yield dst_io
  end

  let!(:dst_io) { ::StringIO.new('', 'w') }
  let!(:output_path) { 'output-path' }

  it 'output result csv file' do
    counter = described_class.new
    counter.record 'tag-1'
    counter.record 'tag-2'
    counter.output output_path

    lines = dst_io.string.lines(chomp: true)
    expect(lines[0]).to eq %q{,tag-1,tag-2}
    # oubject list follows...
  end
end
