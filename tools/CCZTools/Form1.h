#pragma once


namespace CCZTools {

	using namespace System;
	using namespace System::ComponentModel;
	using namespace System::Collections;
	using namespace System::Windows::Forms;
	using namespace System::Data;
	using namespace System::Drawing;
	using namespace System::IO;
	using namespace System::Runtime::InteropServices;

	using namespace FreeImageAPI;

	/// <summary>
	/// Summary for Form1
	/// </summary>
	public ref class Form1 : public System::Windows::Forms::Form
	{
	public:
		Form1(void)
		{
			InitializeComponent();
			//
			//TODO: Add the constructor code here
			//
			pictureBox1->AllowDrop = true;

			globalInit();
		}

	protected:
		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		~Form1()
		{
			globalExit();

			if (components)
			{
				delete components;
			}
		}
	private: System::Windows::Forms::Button^  button2;
	protected: 
	private: System::Windows::Forms::Label^  label3;
	private: System::Windows::Forms::PictureBox^  pictureBox1;
	private: System::Windows::Forms::TextBox^  dstFile;
	private: System::Windows::Forms::TextBox^  srcFile;
	private: System::Windows::Forms::Label^  label2;
	private: System::Windows::Forms::Label^  label1;
	private: System::Windows::Forms::Button^  button1;
	private: System::Windows::Forms::OpenFileDialog^  openFileDialog1;

	private:
		/// <summary>
		/// Required designer variable.
		/// </summary>
		System::ComponentModel::Container ^components;

#pragma region Windows Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		void InitializeComponent(void)
		{
			this->button2 = (gcnew System::Windows::Forms::Button());
			this->label3 = (gcnew System::Windows::Forms::Label());
			this->pictureBox1 = (gcnew System::Windows::Forms::PictureBox());
			this->dstFile = (gcnew System::Windows::Forms::TextBox());
			this->srcFile = (gcnew System::Windows::Forms::TextBox());
			this->label2 = (gcnew System::Windows::Forms::Label());
			this->label1 = (gcnew System::Windows::Forms::Label());
			this->button1 = (gcnew System::Windows::Forms::Button());
			this->openFileDialog1 = (gcnew System::Windows::Forms::OpenFileDialog());
			(cli::safe_cast<System::ComponentModel::ISupportInitialize^  >(this->pictureBox1))->BeginInit();
			this->SuspendLayout();
			// 
			// button2
			// 
			this->button2->Location = System::Drawing::Point(502, 68);
			this->button2->Name = L"button2";
			this->button2->Size = System::Drawing::Size(56, 30);
			this->button2->TabIndex = 15;
			this->button2->Text = L"转换";
			this->button2->UseVisualStyleBackColor = true;
			this->button2->Click += gcnew System::EventHandler(this, &Form1::button2_Click);
			// 
			// label3
			// 
			this->label3->AutoSize = true;
			this->label3->Location = System::Drawing::Point(79, 123);
			this->label3->Name = L"label3";
			this->label3->Size = System::Drawing::Size(65, 12);
			this->label3->TabIndex = 14;
			this->label3->Text = L"图片预览：";
			// 
			// pictureBox1
			// 
			this->pictureBox1->BackgroundImageLayout = System::Windows::Forms::ImageLayout::Stretch;
			this->pictureBox1->BorderStyle = System::Windows::Forms::BorderStyle::FixedSingle;
			this->pictureBox1->Location = System::Drawing::Point(38, 152);
			this->pictureBox1->Name = L"pictureBox1";
			this->pictureBox1->Size = System::Drawing::Size(563, 276);
			this->pictureBox1->SizeMode = System::Windows::Forms::PictureBoxSizeMode::Zoom;
			this->pictureBox1->TabIndex = 13;
			this->pictureBox1->TabStop = false;
			this->pictureBox1->DragDrop += gcnew System::Windows::Forms::DragEventHandler(this, &Form1::pictureBox1_DragDrop);
			this->pictureBox1->DragOver += gcnew System::Windows::Forms::DragEventHandler(this, &Form1::pictureBox1_DragOver);
			// 
			// dstFile
			// 
			this->dstFile->Location = System::Drawing::Point(150, 74);
			this->dstFile->Name = L"dstFile";
			this->dstFile->Size = System::Drawing::Size(334, 21);
			this->dstFile->TabIndex = 12;
			// 
			// srcFile
			// 
			this->srcFile->Location = System::Drawing::Point(150, 20);
			this->srcFile->Name = L"srcFile";
			this->srcFile->ReadOnly = true;
			this->srcFile->Size = System::Drawing::Size(334, 21);
			this->srcFile->TabIndex = 11;
			// 
			// label2
			// 
			this->label2->AutoSize = true;
			this->label2->Location = System::Drawing::Point(79, 77);
			this->label2->Name = L"label2";
			this->label2->Size = System::Drawing::Size(65, 12);
			this->label2->TabIndex = 10;
			this->label2->Text = L"输出文件：";
			// 
			// label1
			// 
			this->label1->AutoSize = true;
			this->label1->Location = System::Drawing::Point(91, 23);
			this->label1->Name = L"label1";
			this->label1->Size = System::Drawing::Size(53, 12);
			this->label1->TabIndex = 9;
			this->label1->Text = L"源文件：";
			// 
			// button1
			// 
			this->button1->Location = System::Drawing::Point(502, 23);
			this->button1->Name = L"button1";
			this->button1->Size = System::Drawing::Size(40, 18);
			this->button1->TabIndex = 8;
			this->button1->Text = L"...";
			this->button1->UseVisualStyleBackColor = true;
			this->button1->Click += gcnew System::EventHandler(this, &Form1::button1_Click);
			// 
			// openFileDialog1
			// 
			this->openFileDialog1->FileName = L"openFileDialog1";
			this->openFileDialog1->Filter = L"jpg文件|*.jpg|png文件|*.png|所有文件(*.*)|*.*";
			// 
			// Form1
			// 
			this->AutoScaleDimensions = System::Drawing::SizeF(6, 12);
			this->AutoScaleMode = System::Windows::Forms::AutoScaleMode::Font;
			this->ClientSize = System::Drawing::Size(641, 440);
			this->Controls->Add(this->button2);
			this->Controls->Add(this->label3);
			this->Controls->Add(this->pictureBox1);
			this->Controls->Add(this->dstFile);
			this->Controls->Add(this->srcFile);
			this->Controls->Add(this->label2);
			this->Controls->Add(this->label1);
			this->Controls->Add(this->button1);
			this->Name = L"Form1";
			this->Text = L"CCZTools";
			(cli::safe_cast<System::ComponentModel::ISupportInitialize^  >(this->pictureBox1))->EndInit();
			this->ResumeLayout(false);
			this->PerformLayout();

		}
#pragma endregion

#pragma region 功能函数

	private:

		void MarshalString( System::String^ src, std::string& des )
		{
			using namespace System::Runtime::InteropServices;

			if( System::String::IsNullOrEmpty(src) )
			{
				des.clear();
				return;
			}

			const char* pChar = (const char* )(Marshal::StringToHGlobalAnsi(src).ToPointer());
			des = pChar;
			Marshal::FreeHGlobal( IntPtr((void*)pChar) );
		}

		System::String^ tocczFileName(System::String^ srcFileName)
		{
			if (Path::GetExtension(srcFileName) == ".ccz")
			{
				return System::String::Empty;
			}

			System::String^ path = Path::GetDirectoryName(srcFileName);
			System::String^ name = Path::GetFileNameWithoutExtension(srcFileName);
			System::String^ ret = path + "\\" + name + ".ccz";

			return ret;
		}

		void setFile(System::String^ pathFile)
		{
			srcFile->Text = pathFile;
			dstFile->Text = tocczFileName(pathFile);

			System::String^ extName = Path::GetExtension(pathFile);

			if( extName == ".ccz" )
			{
				std::string name;
				MarshalString(pathFile, name);

				FILEOPENINFO info = FileSystem::GetSingleton().OpenFile(name, FileSystem::READONLY);
				if( info.m_FileHandle == 0 )
				{
					return;
				}

				Phoenix::String extName;
				Phoenix::OperationSystem::GetFileExtensionName(name, extName);
				Codec* pCodec = Codec::GetCodec(extName);
				Codec::DecodeResult dr = pCodec->Decode(info.m_DataStreamPtr);
				ImageCodec::ImageData* pData = static_cast<ImageCodec::ImageData*>( dr.second.get() );

				FileSystem::GetSingleton().CloseFile(info);

				char* pSrcBuffer;
				long srcLength;
				dr.first->GetBufferData(pSrcBuffer, srcLength);

				PixelBox srcBox(pData->m_Width, pData->m_Height, pData->m_Depth, pData->m_Format, pSrcBuffer);

				PixelFormat pf;
				if( PixelUtil::HasAlpha(pData->m_Format) )
				{
					pf = PF_BYTE_BGRA;
				}
				else
				{
					pf = PF_BYTE_BGR;
				}
				
				long dstLength = PixelUtil::GetMemorySize(pData->m_Width, pData->m_Height, pData->m_Depth, pf);
				char* pDstBuffer = new char[dstLength];

				PixelBox dstBox(pData->m_Width, pData->m_Height, pData->m_Depth, pf, pDstBuffer);
				PixelUtil::BulkPixelConversion(srcBox, dstBox);
				
				FIBITMAP fbitmap = FreeImage::ConvertFromRawBits((IntPtr)pDstBuffer, pData->m_Width, pData->m_Height, pData->m_Width * PixelUtil::GetNumElemBytes(pf), PixelUtil::GetNumElemBits(pf), 0, 0, 0, false);
				pictureBox1->Image = FreeImage::GetBitmap(fbitmap);

				delete [] pDstBuffer;
			}
			else
			{
				pictureBox1->Load(pathFile);
			}
		}

#pragma endregion

	private: System::Void pictureBox1_DragOver(System::Object^  sender, System::Windows::Forms::DragEventArgs^  e)
		{
			if (e->Data->GetDataPresent(DataFormats::FileDrop))
			{
				e->Effect = DragDropEffects::Link;
			}
			else
			{
				e->Effect = DragDropEffects::None;
			}
		}

	private: System::Void pictureBox1_DragDrop(System::Object^  sender, System::Windows::Forms::DragEventArgs^  e)
		{
			System::String^ path = ((System::Array^)e->Data->GetData(DataFormats::FileDrop))->GetValue(0)->ToString();
			if (System::String::IsNullOrEmpty(path))
			{
				return;
			}

			setFile(path);
		}

		/// <summary>
		/// 选择源文件
		/// </summary>
	private: System::Void button1_Click(System::Object^  sender, System::EventArgs^  e)
		{
			System::Windows::Forms::DialogResult dr = openFileDialog1->ShowDialog(this);
			if (dr == System::Windows::Forms::DialogResult::OK)
			{
				setFile(openFileDialog1->FileNames[0]);
			}
		}

		/// <summary>
		/// 转换
		/// </summary>
	private: System::Void button2_Click(System::Object^  sender, System::EventArgs^  e)
		{
			std::string name;
			MarshalString(srcFile->Text, name);

			converter2CCZ(name);
		}

};
}

