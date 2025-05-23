require 'spec_helper'

module Bosh::Director
  describe RenderedJobTemplatesCleaner do
    subject(:rendered_job_templates) { described_class.new(instance_model, blobstore, per_spec_logger) }
    let(:instance_model) { FactoryBot.create(:models_instance) }
    let(:blobstore) { instance_double('Bosh::Director::Blobstore::Client') }

    describe '#clean' do
      let(:stale_archive) do
        FactoryBot.create(:models_rendered_templates_archive,
          blobstore_id: 'fake-blob-id',
          instance: instance_model,
          created_at: Time.new(2013, 0o2, 0o1),
        )
      end

      it 'removes *stale* archives from the blobstore and then from the database' do
        allow(instance_model).to receive(:stale_rendered_templates_archives).and_return([stale_archive])
        expect(blobstore).to receive(:delete).with('fake-blob-id').ordered
        expect(stale_archive).to receive(:delete).with(no_args).ordered

        rendered_job_templates.clean
      end

      it 'removes *stale* archives from the database even if the archives are not in the blobstore' do
        allow(instance_model).to receive(:stale_rendered_templates_archives).and_return([stale_archive])
        expect(blobstore).to receive(:delete).with('fake-blob-id').and_raise Bosh::Director::Blobstore::NotFound
        expect(per_spec_logger).to receive(:debug).with(
          'Blobstore#delete error: Bosh::Director::Blobstore::NotFound, will ignore this error and delete the db record',
        )
        expect(stale_archive).to receive(:delete).with(no_args)

        rendered_job_templates.clean
      end
    end

    describe '#clean_all' do
      let(:stale_archive) do
        FactoryBot.create(:models_rendered_templates_archive,
          blobstore_id: 'fake-blob-id',
          instance: instance_model,
          created_at: Time.new(2013, 0o2, 0o1),
        )
      end

      it 'removes *all* archives from the blobstore and then from the database' do
        allow(instance_model).to receive(:rendered_templates_archives).and_return([stale_archive])
        expect(blobstore).to receive(:delete).with('fake-blob-id').ordered
        expect(stale_archive).to receive(:delete).with(no_args).ordered

        rendered_job_templates.clean_all
      end

      it 'removes *all* archives from the database even if the archives are not in the blobstore' do
        allow(instance_model).to receive(:rendered_templates_archives).and_return([stale_archive])
        expect(blobstore).to receive(:delete).with('fake-blob-id').and_raise Bosh::Director::Blobstore::NotFound
        expect(per_spec_logger).to receive(:debug).with(
          'Blobstore#delete error: Bosh::Director::Blobstore::NotFound, will ignore this error and delete the db record',
        )
        expect(stale_archive).to receive(:delete).with(no_args)

        rendered_job_templates.clean_all
      end
    end
  end
end
