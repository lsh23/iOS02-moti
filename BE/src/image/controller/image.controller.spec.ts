import { ImageService } from '../application/image.service';
import {
  anyOfClass,
  anything,
  instance,
  mock,
  objectContaining,
  when,
} from 'ts-mockito';
import { Image } from '../domain/image.domain';
import { User } from '../../users/domain/user.domain';
import { Test, TestingModule } from '@nestjs/testing';
import { AppModule } from '../../app.module';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { AuthFixture } from '../../../test/auth/auth-fixture';
import * as request from 'supertest';
import { AuthTestModule } from '../../../test/auth/auth-test.module';
import * as path from 'path';
import * as process from 'process';
import { FailFileTaskException } from '../../common/application/file-store/fail-file-task.exception';
import { validationPipeOptions } from '../../config/validation';
import { UnexpectedExceptionFilter } from '../../common/filter/unexpected-exception.filter';
import { MotimateExceptionFilter } from '../../common/filter/exception.filter';

describe('ImageController', () => {
  let app: INestApplication;
  let authFixture: AuthFixture;

  beforeAll(async () => {
    const mockImageService = mock<ImageService>(ImageService);
    const defaultImage = new Image(null);
    defaultImage.id = 1004;
    defaultImage.originalName = 'image1.jpg';
    defaultImage.imageUrl = 'file://abcd-efgh-ijkl-mnop.jpg';
    when(mockImageService.saveImage(anything(), anyOfClass(User))).thenResolve(
      defaultImage,
    );
    when(
      mockImageService.saveImage(
        objectContaining({ originalname: 'error.png' }),
        anyOfClass(User),
      ),
    ).thenThrow(new FailFileTaskException());

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule, AuthTestModule],
      controllers: [],
      providers: [],
    })
      .overrideProvider(ImageService)
      .useValue(instance<ImageService>(mockImageService))
      .compile();

    authFixture = moduleFixture.get<AuthFixture>(AuthFixture);
    app = moduleFixture.createNestApplication();

    app.useGlobalPipes(new ValidationPipe(validationPipeOptions));
    app.useGlobalFilters(
      new UnexpectedExceptionFilter(),
      new MotimateExceptionFilter(),
    );

    await app.init();
  });

  describe('테스트 환경 확인', () => {
    it('app가 정의되어 있어야 한다.', () => {
      expect(app).toBeDefined();
    });
  });

  describe('saveImage는 이미지를 저장할 수 있다.', () => {
    it('이미지 저장에 성공하면 id와 imageURL을 포함한다.', async () => {
      const { accessToken } = await authFixture.getAuthenticatedUser('ABC');

      return request(app.getHttpServer())
        .post('/api/v1/images')
        .set('Authorization', `Bearer ${accessToken}`)
        .attach('image', path.join(process.cwd(), '/test/resources/img.png'))
        .expect(201)
        .expect((res: request.Response) => {
          expect(res.body.success).toBe(true);
          expect(res.body.data).toEqual({
            id: 1004,
            imageUrl: 'file://abcd-efgh-ijkl-mnop.jpg',
          });
        });
    });

    it('이미지 저장에 실패하면 success가 false이고 500 stausCode를 가진다.', async () => {
      const { accessToken } = await authFixture.getAuthenticatedUser('ABC');

      return request(app.getHttpServer())
        .post('/api/v1/images')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(400)
        .expect((res: request.Response) => {
          expect(res.body.success).toBe(false);
          expect(res.body.message).toBe('파일을 선택해주세요.');
        });
    });

    it('이미지 저장에 실패하면 success가 false이고 500 stausCode를 가진다.', async () => {
      const { accessToken } = await authFixture.getAuthenticatedUser('ABC');

      return request(app.getHttpServer())
        .post('/api/v1/images')
        .set('Authorization', `Bearer ${accessToken}`)
        .attach('image', path.join(process.cwd(), '/test/resources/error.png'))
        .expect(500)
        .expect((res: request.Response) => {
          expect(res.body.success).toBe(false);
          expect(res.body.message).toBe('파일 요청 작업에 실패했습니다.');
        });
    });
  });
});
