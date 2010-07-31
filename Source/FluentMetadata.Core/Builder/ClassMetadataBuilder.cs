namespace FluentMetadata.Builder
{
    internal class ClassMetadataBuilder<T> : IClassBuilder<T>
    {
        private IDisplayClass<T> displayBuilder;

        private readonly Metadata metadata;

        public ClassMetadataBuilder(Metadata metadata)
        {
            this.metadata = metadata;
            metadata.ModelType = typeof (T);
            metadata.ModelName = typeof (T).Name;
        }

        public IDisplayClass<T> Display
        {
            get
            {
                if (displayBuilder == null)
                    displayBuilder = new DisplayBuilder<T>(this);
                return displayBuilder;
            }
        }

        public Metadata Metadata
        {
            get { return metadata; }
        }
    }
}